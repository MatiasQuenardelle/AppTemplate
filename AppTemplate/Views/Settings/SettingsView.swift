import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showBugReport = false
    @State private var showDeleteConfirmation = false
    @State private var showSignOutConfirmation = false
    @State private var editingName = false
    @State private var nameText = ""

    private var authService: AuthenticationService { AuthenticationService.shared }
    private var profileCache: ProfileCacheService { ProfileCacheService.shared }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.deepBlack.ignoresSafeArea()

                List {
                    // Profile Section
                    Section {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Theme.copperGold.opacity(0.2))
                                    .frame(width: 50, height: 50)

                                Text(String(profileCache.name.prefix(1)).uppercased())
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(Theme.copperGold)
                            }
                            .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: 4) {
                                if editingName {
                                    TextField(Strings.Settings.name, text: $nameText, onCommit: saveName)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(Theme.primaryText)
                                } else {
                                    Text(profileCache.name)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(Theme.primaryText)
                                }

                                Text(authService.currentUser?.email ?? Strings.Settings.notSignedIn)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.secondaryText)
                            }

                            Spacer()

                            Button {
                                if editingName {
                                    saveName()
                                } else {
                                    nameText = profileCache.name
                                    editingName = true
                                }
                            } label: {
                                Image(systemName: editingName ? "checkmark" : "pencil")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Theme.copperGold)
                            }
                            .accessibilityLabel(editingName ? "Save name" : "Edit name")
                        }
                        .listRowBackground(Theme.cardBackground)
                    }

                    // Sync Section
                    Section(Strings.Settings.syncSection) {
                        SyncStatusButton()
                            .listRowBackground(Theme.cardBackground)
                    }

                    // Subscription Section
                    Section(Strings.Settings.subscriptionSection) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Theme.copperGold)
                                .frame(width: 24)
                                .accessibilityHidden(true)

                            Text(Strings.Settings.premium)
                                .foregroundStyle(Theme.primaryText)

                            Spacer()

                            Text(SubscriptionManager.shared.isPremium ? Strings.Settings.premiumActive : Strings.Settings.premiumFree)
                                .font(.caption)
                                .foregroundStyle(SubscriptionManager.shared.isPremium ? .green : Theme.secondaryText)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Premium subscription, \(SubscriptionManager.shared.isPremium ? "active" : "free")")
                        .listRowBackground(Theme.cardBackground)

                        Button {
                            Task {
                                await SubscriptionManager.shared.restorePurchases()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundStyle(Theme.copperGold)
                                    .frame(width: 24)
                                Text(Strings.Settings.restorePurchases)
                                    .foregroundStyle(Theme.primaryText)
                            }
                        }
                        .listRowBackground(Theme.cardBackground)
                    }

                    // Support Section
                    Section(Strings.Settings.supportSection) {
                        Button {
                            showBugReport = true
                        } label: {
                            HStack {
                                Image(systemName: "ladybug")
                                    .foregroundStyle(Theme.salmonAccent)
                                    .frame(width: 24)
                                Text(Strings.Settings.reportBug)
                                    .foregroundStyle(Theme.primaryText)
                            }
                        }
                        .listRowBackground(Theme.cardBackground)
                    }

                    // Account Section
                    if authService.isAuthenticated {
                        Section(Strings.Settings.accountSection) {
                            Button {
                                showSignOutConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundStyle(.orange)
                                        .frame(width: 24)
                                    Text(Strings.Settings.signOut)
                                        .foregroundStyle(.orange)
                                }
                            }
                            .listRowBackground(Theme.cardBackground)

                            Button {
                                showDeleteConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                        .frame(width: 24)
                                    Text(Strings.Settings.deleteAccount)
                                        .foregroundStyle(.red)
                                }
                            }
                            .listRowBackground(Theme.cardBackground)
                        }
                    }

                    // App Info
                    Section {
                        HStack {
                            Text(Strings.Settings.version)
                                .foregroundStyle(Theme.secondaryText)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                .foregroundStyle(Theme.tertiaryText)
                        }
                        .listRowBackground(Theme.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(Strings.Settings.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Theme.deepBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showBugReport) {
                BugReportView()
            }
            .alert(Strings.Settings.signOut, isPresented: $showSignOutConfirmation) {
                Button(Strings.Settings.cancel, role: .cancel) {}
                Button(Strings.Settings.signOut, role: .destructive) { signOut() }
            } message: {
                Text(Strings.Settings.signOutConfirmation)
            }
            .alert(Strings.Settings.deleteAccount, isPresented: $showDeleteConfirmation) {
                Button(Strings.Settings.cancel, role: .cancel) {}
                Button(Strings.Settings.delete, role: .destructive) { deleteAccount() }
            } message: {
                Text(Strings.Settings.deleteAccountWarning)
            }
        }
    }

    private func saveName() {
        let name = nameText.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { editingName = false; return }

        var descriptor = FetchDescriptor<UserProfile>()
        descriptor.fetchLimit = 1

        if let profile = try? modelContext.fetch(descriptor).first {
            profile.name = name
            SyncManager.shared.markNeedsSync(profile)
            ProfileCacheService.shared.invalidate()
        }

        editingName = false
    }

    private func signOut() {
        do {
            try authService.signOut()
        } catch {
            print("[Settings] sign out error: \(error)")
        }
    }

    private func deleteAccount() {
        Task { @MainActor in
            do {
                // Delete cloud data first
                if let userId = authService.currentUser?.uid {
                    try await FirestoreService.shared.deleteAllUserData(userId: userId)
                }
                try await authService.deleteAccount()
            } catch {
                print("[Settings] delete account error: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserProfile.self, Note.self], inMemory: true)
}
