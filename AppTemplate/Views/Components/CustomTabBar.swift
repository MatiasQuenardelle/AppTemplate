import SwiftUI

// MARK: - EXAMPLE: Tab enum — replace .notes and .search with your own tabs.
enum Tab: Int, CaseIterable {
    case notes = 0    // EXAMPLE — replace with your first tab
    case search = 1   // EXAMPLE — replace with your second tab
    case settings = 2

    var title: String {
        switch self {
        case .notes: return "Notes"      // EXAMPLE
        case .search: return "Search"    // EXAMPLE
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .notes: return "note.text"          // EXAMPLE
        case .search: return "magnifyingglass"   // EXAMPLE
        case .settings: return "gearshape"
        }
    }
}
// MARK: END EXAMPLE

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabBarButton(tab: tab, selectedTab: $selectedTab)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .background(
            Rectangle()
                .fill(Theme.tabBarBackground)
                .shadow(color: .black.opacity(0.5), radius: 15, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let tab: Tab
    @Binding var selectedTab: Tab

    private var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .symbolEffect(.bounce, value: isSelected)

                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(isSelected ? Theme.selectedTint : Theme.unselectedTint)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab: Tab = .notes

        var body: some View {
            ZStack {
                Theme.deepBlack.ignoresSafeArea()

                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    return PreviewWrapper()
}
