import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseCrashlytics
import FirebaseFirestore
import GoogleSignIn
import UserNotifications

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        #if DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        #endif
        FirestoreService.shared.configureSync()
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([])
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let cloudSyncCompleted = Notification.Name("cloudSyncCompleted")
    static let userDidSignIn = Notification.Name("userDidSignIn")
}

// MARK: - Deep Link Actions

enum DeepLinkAction: Equatable {
    case none
}

// MARK: - App State

class AppState: ObservableObject {
    @Published var deepLinkAction: DeepLinkAction = .none

    func handleDeepLink(_ url: URL) {
        guard url.scheme == Constants.App.urlScheme else { return }
        // Add deep link handling here
    }

    func clearDeepLinkAction() {
        deepLinkAction = .none
    }
}

// MARK: - App Entry Point

@main
struct AppTemplateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Note.self  // MARK: EXAMPLE — remove Note.self when removing the Example module.
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onOpenURL { url in
                    if GIDSignIn.sharedInstance.handle(url) {
                        return
                    }
                    appState.handleDeepLink(url)
                }
                .onAppear {
                    ProfileCacheService.shared.configure(with: sharedModelContainer)
                    SubscriptionManager.shared.configure()
                }
                .onReceive(NotificationCenter.default.publisher(for: .userDidSignIn)) { _ in
                    Task { @MainActor in
                        if let userId = AuthenticationService.shared.currentUser?.uid {
                            let context = ModelContext(sharedModelContainer)
                            await SyncManager.shared.configure(userId: userId, modelContext: context)
                            await SubscriptionManager.shared.login(firebaseUID: userId)
                        }
                    }
                }
                .task {
                    // Poll for Firebase auth state restoration
                    for _ in 0..<10 {
                        if AuthenticationService.shared.currentUser != nil { break }
                        try? await Task.sleep(nanoseconds: 50_000_000)
                    }

                    if let userId = AuthenticationService.shared.currentUser?.uid {
                        let context = ModelContext(sharedModelContainer)
                        await SyncManager.shared.configure(userId: userId, modelContext: context)
                        await SubscriptionManager.shared.login(firebaseUID: userId)
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
