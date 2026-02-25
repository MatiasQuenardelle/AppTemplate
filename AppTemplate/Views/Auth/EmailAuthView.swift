import SwiftUI

struct EmailAuthView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = false
    @State private var showForgotPassword = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showSuccessMessage = false

    let onSuccess: () -> Void

    private var isFormValid: Bool {
        let emailValid = email.contains("@") && email.contains(".")
        let passwordValid = password.count >= 6

        if isSignUp {
            return emailValid && passwordValid && password == confirmPassword
        }
        return emailValid && passwordValid
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.deepBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Theme.accentCoral.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(Theme.accentCoral)
                            }

                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(Theme.primaryText)
                        }
                        .padding(.top, 40)

                        // Form
                        VStack(spacing: 16) {
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.secondaryText)

                                TextField("", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .font(.system(size: 16))
                                    .foregroundStyle(Theme.primaryText)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Theme.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Theme.tertiaryText.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }

                            // Password field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.secondaryText)

                                SecureField("", text: $password)
                                    .textContentType(isSignUp ? .newPassword : .password)
                                    .font(.system(size: 16))
                                    .foregroundStyle(Theme.primaryText)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Theme.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Theme.tertiaryText.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }

                            // Confirm password (sign up only)
                            if isSignUp {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Confirm Password")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Theme.secondaryText)

                                    SecureField("", text: $confirmPassword)
                                        .textContentType(.newPassword)
                                        .font(.system(size: 16))
                                        .foregroundStyle(Theme.primaryText)
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Theme.cardBackground)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(
                                                            password != confirmPassword && !confirmPassword.isEmpty
                                                                ? Color.red.opacity(0.5)
                                                                : Theme.tertiaryText.opacity(0.3),
                                                            lineWidth: 1
                                                        )
                                                )
                                        )

                                    if password != confirmPassword && !confirmPassword.isEmpty {
                                        Text("Passwords do not match")
                                            .font(.caption)
                                            .foregroundStyle(.red)
                                    }
                                }
                            }

                            // Forgot password
                            if !isSignUp {
                                HStack {
                                    Spacer()
                                    Button("Forgot your password?") {
                                        showForgotPassword = true
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.accentCoral)
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // Submit button
                        Button {
                            submitForm()
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(isFormValid ? Color.white : Color.white.opacity(0.5))
                            )
                        }
                        .disabled(!isFormValid || isLoading)
                        .padding(.horizontal, 24)

                        // Toggle sign up/sign in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isSignUp.toggle()
                                confirmPassword = ""
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                    .foregroundStyle(Theme.secondaryText)
                                Text(isSignUp ? "Sign In" : "Sign Up")
                                    .foregroundStyle(Theme.accentCoral)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 14))
                        }

                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
            .alert("Email Sent", isPresented: $showSuccessMessage) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Check your inbox to reset your password")
            }
        }
    }

    private func submitForm() {
        isLoading = true

        Task { @MainActor in
            do {
                if isSignUp {
                    try await AuthenticationService.shared.signUpWithEmail(email: email, password: password)
                } else {
                    try await AuthenticationService.shared.signInWithEmail(email: email, password: password)
                }
                try await AuthenticationService.shared.configureSyncIfNeededThrowing(modelContext: modelContext)
                isLoading = false
                onSuccess()
                dismiss()
            } catch {
                isLoading = false
                errorMessage = "Sign in failed: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    private var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.deepBlack.ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Theme.accentCoral.opacity(0.2))
                                .frame(width: 80, height: 80)
                            Image(systemName: "key.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(Theme.accentCoral)
                        }

                        Text("Reset Password")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Theme.primaryText)

                        Text("Enter your email and we'll send you a link to reset your password")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 40)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.secondaryText)

                        TextField("", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.primaryText)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Theme.tertiaryText.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal, 24)

                    Button {
                        sendResetEmail()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Send Reset Link")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isEmailValid ? Color.white : Color.white.opacity(0.5))
                        )
                    }
                    .disabled(!isEmailValid || isLoading)
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Email Sent", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("Check your inbox to reset your password")
            }
        }
    }

    private func sendResetEmail() {
        isLoading = true

        Task {
            do {
                try await AuthenticationService.shared.sendPasswordReset(email: email)
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    EmailAuthView(onSuccess: {})
}
