import SwiftUI
import UserNotifications

// MARK: - Welcome Phase

struct WelcomePhaseView: View {
    let onContinue: () -> Void
    let onSignIn: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App icon area
            ZStack {
                Circle()
                    .fill(Theme.copperGold.opacity(0.15))
                    .frame(width: 140, height: 140)

                Image(systemName: "note.text")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.copperGold)
            }

            VStack(spacing: 12) {
                Text("Welcome to \(Constants.App.displayName)")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.primaryText)
                    .multilineTextAlignment(.center)

                Text("Your notes, synced everywhere.")
                    .font(.system(size: 17))
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    onContinue()
                } label: {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    onSignIn()
                } label: {
                    Text("I already have an account")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.secondaryText)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Name Input Phase

struct NameInputPhaseView: View {
    @Binding var name: String
    let onContinue: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Text("What's your name?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Theme.primaryText)

                Text("We'll use this to personalize your experience.")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            TextField("Your name", text: $name)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Theme.primaryText)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.words)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Theme.tertiaryText.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 32)
                .focused($isFocused)

            Spacer()

            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        !name.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color.white
                            : Color.white.opacity(0.5),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear { isFocused = true }
    }
}

// MARK: - Notifications Phase

struct NotificationsPhaseView: View {
    @Binding var notificationsGranted: Bool
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.copperGold.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Theme.copperGold)
            }

            VStack(spacing: 12) {
                Text("Stay Updated")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Theme.primaryText)

                Text("Get reminders and sync notifications so you never miss anything.")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    requestNotifications()
                } label: {
                    Text("Enable Notifications")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    onContinue()
                } label: {
                    Text("Maybe Later")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.secondaryText)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            Task { @MainActor in
                notificationsGranted = granted
                onContinue()
            }
        }
    }
}

// MARK: - Paywall Phase

struct PaywallPhaseView: View {
    let onComplete: () -> Void
    let onRestore: () -> Void

    @State private var selectedPlan: String = "yearly"

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("Unlock Premium")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.primaryText)

                Text("Sync across devices, unlimited notes, and more.")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "icloud.fill", text: "Cloud sync across all devices")
                FeatureRow(icon: "infinity", text: "Unlimited notes")
                FeatureRow(icon: "sparkles", text: "AI-powered summaries")
                FeatureRow(icon: "lock.shield.fill", text: "End-to-end encryption")
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                // Subscribe button (placeholder)
                Button {
                    Task {
                        await SubscriptionManager.shared.fetchOfferings()
                        if let yearly = SubscriptionManager.shared.yearlyPackage {
                            _ = try? await SubscriptionManager.shared.purchase(yearly)
                        }
                        onComplete()
                    }
                } label: {
                    Text("Start Free Trial")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
                }

                // Restore
                Button {
                    onRestore()
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.secondaryText)
                }

                // Skip
                Button {
                    onComplete()
                } label: {
                    Text("Continue without Premium")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.tertiaryText)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Theme.copperGold)
                .frame(width: 28)

            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(Theme.primaryText)
        }
    }
}
