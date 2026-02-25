import Foundation
import SwiftData
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

// MARK: - Authentication Error

enum AuthenticationError: LocalizedError, Equatable {
    case noRootViewController
    case appleSignInFailed
    case googleSignInFailed
    case invalidCredential
    case networkError
    case userCancelled
    case unknown(Error)

    static func == (lhs: AuthenticationError, rhs: AuthenticationError) -> Bool {
        switch (lhs, rhs) {
        case (.noRootViewController, .noRootViewController),
             (.appleSignInFailed, .appleSignInFailed),
             (.googleSignInFailed, .googleSignInFailed),
             (.invalidCredential, .invalidCredential),
             (.networkError, .networkError),
             (.userCancelled, .userCancelled):
            return true
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }

    var errorDescription: String? {
        switch self {
        case .noRootViewController:
            return "Could not present the sign-in screen"
        case .appleSignInFailed:
            return "Apple sign-in failed"
        case .googleSignInFailed:
            return "Google sign-in failed"
        case .invalidCredential:
            return "Invalid credentials"
        case .networkError:
            return "Connection error. Check your internet"
        case .userCancelled:
            return "Sign-in cancelled"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Authentication Service

@Observable
final class AuthenticationService: NSObject, @unchecked Sendable {
    static let shared = AuthenticationService()

    private(set) var currentUser: FirebaseAuth.User?
    var isAuthenticated: Bool { currentUser != nil }
    var isLoading = false
    var errorMessage: String?

    // Apple Sign-In state
    private var currentNonce: String?
    private var appleSignInContinuation: CheckedContinuation<Void, Error>?

    private override init() {
        super.init()
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                let wasSignedOut = self?.currentUser == nil
                self?.currentUser = user

                if wasSignedOut && user != nil {
                    NotificationCenter.default.post(name: .userDidSignIn, object: nil)
                }
            }
        }
    }

    // MARK: - Sync Integration

    @MainActor
    func configureSyncIfNeeded(modelContext: ModelContext) async {
        guard let userId = currentUser?.uid else { return }
        await SyncManager.shared.configure(userId: userId, modelContext: modelContext)
    }

    @MainActor
    func configureSyncIfNeededThrowing(modelContext: ModelContext) async throws {
        guard let userId = currentUser?.uid else {
            throw AuthenticationError.unknown(
                NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user ID available"])
            )
        }
        try await SyncManager.shared.configureWithErrorHandling(userId: userId, modelContext: modelContext)
    }

    @MainActor
    func stopSync() {
        SyncManager.shared.stopListening()
    }

    // MARK: - Apple Sign-In

    @MainActor
    func signInWithApple() async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let nonce = randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self

        return try await withCheckedThrowingContinuation { continuation in
            self.appleSignInContinuation = continuation
            authorizationController.performRequests()
        }
    }

    // MARK: - Google Sign-In

    @MainActor
    func signInWithGoogle() async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthenticationError.googleSignInFailed
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthenticationError.noRootViewController
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthenticationError.googleSignInFailed
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            try await Auth.auth().signIn(with: credential)
        } catch let error as GIDSignInError where error.code == .canceled {
            throw AuthenticationError.userCancelled
        } catch {
            throw AuthenticationError.unknown(error)
        }
    }

    // MARK: - Email/Password Sign-In

    @MainActor
    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Email/Password Sign-Up

    @MainActor
    func signUpWithEmail(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Password Reset

    @MainActor
    func sendPasswordReset(email: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Sign Out

    func signOut() throws {
        Task { @MainActor in
            stopSync()
            await SubscriptionManager.shared.logout()
        }

        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch {
            throw AuthenticationError.unknown(error)
        }
    }

    // MARK: - Delete Account

    @MainActor
    func deleteAccount() async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let user = Auth.auth().currentUser else { return }

        await SubscriptionManager.shared.logout()

        do {
            try await user.delete()
            GIDSignIn.sharedInstance.signOut()
        } catch let error as NSError {
            if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                throw AuthenticationError.invalidCredential
            }
            throw AuthenticationError.unknown(error)
        }
    }

    // MARK: - Helper Methods

    private func mapFirebaseError(_ error: NSError) -> AuthenticationError {
        guard error.domain == AuthErrorDomain else {
            return .unknown(error)
        }

        switch error.code {
        case AuthErrorCode.networkError.rawValue:
            return .networkError
        case AuthErrorCode.wrongPassword.rawValue,
             AuthErrorCode.invalidEmail.rawValue,
             AuthErrorCode.userNotFound.rawValue:
            return .invalidCredential
        default:
            return .unknown(error)
        }
    }

    // MARK: - Nonce Generation for Apple Sign-In

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthenticationService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            appleSignInContinuation?.resume(throwing: AuthenticationError.appleSignInFailed)
            appleSignInContinuation = nil
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        Task { @MainActor in
            do {
                try await Auth.auth().signIn(with: credential)
                appleSignInContinuation?.resume()
            } catch {
                appleSignInContinuation?.resume(throwing: AuthenticationError.unknown(error))
            }
            appleSignInContinuation = nil
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            appleSignInContinuation?.resume(throwing: AuthenticationError.userCancelled)
        } else {
            appleSignInContinuation?.resume(throwing: AuthenticationError.appleSignInFailed)
        }
        appleSignInContinuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthenticationService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        let activeScene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let windowScene = activeScene ?? (scenes.first as? UIWindowScene)
        return windowScene?.keyWindow
            ?? windowScene?.windows.first
            ?? UIWindow()
    }
}
