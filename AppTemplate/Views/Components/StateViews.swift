import SwiftUI

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Theme.tertiaryText)
                .accessibilityHidden(true)

            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.primaryText)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let actionTitle, let action {
                Button {
                    action()
                } label: {
                    Text(actionTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.copperGold)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Loading State View

struct LoadingStateView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(Theme.copperGold)

            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error State View

struct ErrorStateView: View {
    let message: String
    var retryTitle: String = "Try Again"
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            Text("Something went wrong")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.primaryText)

            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let onRetry {
                Button {
                    onRetry()
                } label: {
                    Text(retryTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Previews

#Preview("Empty State") {
    ZStack {
        Theme.deepBlack.ignoresSafeArea()
        EmptyStateView(
            icon: "note.text",
            title: "No Notes Yet",
            message: "Tap the + button to create your first note.",
            actionTitle: "Create Note",
            action: {}
        )
    }
}

#Preview("Loading State") {
    ZStack {
        Theme.deepBlack.ignoresSafeArea()
        LoadingStateView()
    }
}

#Preview("Error State") {
    ZStack {
        Theme.deepBlack.ignoresSafeArea()
        ErrorStateView(
            message: "Could not load your data. Check your internet connection.",
            onRetry: {}
        )
    }
}
