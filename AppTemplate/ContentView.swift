import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var selectedTab: Tab = .notes
    @State private var showOnboarding = false

    private var authService: AuthenticationService { AuthenticationService.shared }
    private var profileCache: ProfileCacheService { ProfileCacheService.shared }

    var body: some View {
        ZStack {
            Theme.deepBlack.ignoresSafeArea()

            if hasCompletedOnboarding {
                mainContent
            } else {
                OnboardingContainerView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                profileCache.refresh()
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Tab content
            Group {
                switch selectedTab {
                // MARK: EXAMPLE: Tab cases — replace with your own tabs.
                case .notes:
                    NotesListView()
                case .search:
                    SearchView()
                // MARK: END EXAMPLE
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .modelContainer(for: [UserProfile.self, Note.self], inMemory: true) // MARK: EXAMPLE — remove Note.self
}
