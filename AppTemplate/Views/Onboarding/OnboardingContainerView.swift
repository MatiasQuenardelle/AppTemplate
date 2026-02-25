import SwiftUI
import SwiftData

// MARK: - Onboarding Container View

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var state = OnboardingState()
    @State private var showEmailAuth = false
    @State private var showSignIn = false

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Theme.deepBlack.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar (hidden on welcome)
                if state.currentPhase != .welcome {
                    ProgressView(value: state.currentPhase.progressValue)
                        .tint(Theme.copperGold)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                }

                // Back button
                if state.canGoBack && state.currentPhase != .welcome {
                    HStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                state.goBack()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.secondaryText)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }

                // Phase content
                phaseContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .animation(.easeInOut(duration: 0.3), value: state.currentPhase)
            }
        }
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthView {
                completeOnboarding()
            }
        }
        .sheet(isPresented: $showSignIn) {
            EmailAuthView {
                // Already signed in, configure sync
                Task { @MainActor in
                    try? await AuthenticationService.shared.configureSyncIfNeededThrowing(modelContext: modelContext)
                }
                onComplete()
            }
        }
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch state.currentPhase {
        case .welcome:
            WelcomePhaseView(
                onContinue: {
                    withAnimation { state.advance() }
                },
                onSignIn: {
                    showSignIn = true
                }
            )

        case .nameInput:
            NameInputPhaseView(name: $state.userName) {
                withAnimation { state.advance() }
            }

        case .notifications:
            NotificationsPhaseView(notificationsGranted: $state.notificationsGranted) {
                withAnimation { state.advance() }
            }

        case .paywall:
            PaywallPhaseView(
                onComplete: {
                    completeOnboarding()
                },
                onRestore: {
                    Task {
                        await SubscriptionManager.shared.restorePurchases()
                        completeOnboarding()
                    }
                }
            )
        }
    }

    private func completeOnboarding() {
        let name = state.userName.trimmingCharacters(in: .whitespaces)

        // Update or create profile
        let context = modelContext
        var descriptor = FetchDescriptor<UserProfile>()
        descriptor.fetchLimit = 1

        let profile: UserProfile
        if let existing = try? context.fetch(descriptor).first {
            profile = existing
        } else {
            profile = UserProfile()
            context.insert(profile)
        }

        profile.name = name.isEmpty ? "User" : name
        profile.hasCompletedOnboarding = true
        profile.needsSync = true
        profile.updatedAt = Date()

        try? context.save()

        // Update caches
        ProfileCacheService.shared.updateCachedProfile(profile)
        SyncManager.shared.markNeedsSync(profile)

        onComplete()
    }
}

#Preview {
    OnboardingContainerView(onComplete: {})
}
