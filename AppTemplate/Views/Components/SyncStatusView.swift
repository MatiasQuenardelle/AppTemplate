import SwiftUI

// MARK: - Sync Status View

struct SyncStatusView: View {
    private var syncManager: SyncManager { SyncManager.shared }

    var body: some View {
        HStack(spacing: 4) {
            statusIcon
            statusText
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(syncAccessibilityLabel)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch syncManager.syncStatus {
        case .idle:
            if syncManager.lastSyncDate != nil {
                Image(systemName: "checkmark.icloud")
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "icloud")
                    .foregroundStyle(.secondary)
            }
        case .syncing:
            ProgressView()
                .controlSize(.mini)
        case .error:
            Image(systemName: "exclamationmark.icloud")
                .foregroundStyle(.orange)
        case .offline:
            Image(systemName: "icloud.slash")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var statusText: some View {
        switch syncManager.syncStatus {
        case .idle:
            if let lastSync = syncManager.lastSyncDate {
                Text(lastSyncText(lastSync))
            } else {
                Text(Strings.Sync.notSynced)
            }
        case .syncing:
            Text(Strings.Sync.syncing)
        case .error(let message):
            Text(message)
                .lineLimit(1)
        case .offline:
            Text(Strings.Sync.offline)
        }
    }

    private func lastSyncText(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 {
            return Strings.Sync.justNow
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return Strings.Sync.minutesAgo(minutes)
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return Strings.Sync.hoursAgo(hours)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }

    private var syncAccessibilityLabel: String {
        switch syncManager.syncStatus {
        case .idle:
            if let lastSync = syncManager.lastSyncDate {
                return "Synced \(lastSyncText(lastSync))"
            }
            return Strings.Sync.notSynced
        case .syncing:
            return Strings.Sync.syncingData
        case .error(let message):
            return "Sync error: \(message)"
        case .offline:
            return Strings.Sync.noConnection
        }
    }
}

// MARK: - Compact Sync Indicator

struct CompactSyncIndicator: View {
    private var syncManager: SyncManager { SyncManager.shared }

    var body: some View {
        Group {
            switch syncManager.syncStatus {
            case .idle:
                if syncManager.lastSyncDate != nil {
                    Image(systemName: "checkmark.icloud")
                        .foregroundStyle(.green.opacity(0.7))
                } else {
                    Image(systemName: "icloud")
                        .foregroundStyle(.secondary)
                }
            case .syncing:
                ProgressView()
                    .controlSize(.mini)
            case .error:
                Image(systemName: "exclamationmark.icloud")
                    .foregroundStyle(.orange)
            case .offline:
                Image(systemName: "icloud.slash")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.footnote)
    }
}

// MARK: - Sync Button for Settings

struct SyncStatusButton: View {
    private var syncManager: SyncManager { SyncManager.shared }
    private var authService: AuthenticationService { AuthenticationService.shared }

    var body: some View {
        Button {
            Task { @MainActor in
                await syncManager.syncAll()
            }
        } label: {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(Strings.Sync.cloudSync)
                        .foregroundStyle(.primary)

                    Text(statusDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if syncManager.syncStatus.isActive {
                    ProgressView()
                        .controlSize(.small)
                } else if syncManager.pendingChangesCount > 0 {
                    Text("\(syncManager.pendingChangesCount)")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.orange, in: Capsule())
                }
            }
        }
        .disabled(syncManager.syncStatus.isActive || !authService.isAuthenticated)
    }

    private var statusIcon: String {
        switch syncManager.syncStatus {
        case .idle:
            return syncManager.lastSyncDate != nil ? "checkmark.icloud.fill" : "icloud"
        case .syncing:
            return "arrow.triangle.2.circlepath.icloud"
        case .error:
            return "exclamationmark.icloud.fill"
        case .offline:
            return "icloud.slash"
        }
    }

    private var statusColor: Color {
        switch syncManager.syncStatus {
        case .idle:
            return syncManager.lastSyncDate != nil ? .green : .secondary
        case .syncing:
            return .blue
        case .error:
            return .orange
        case .offline:
            return .secondary
        }
    }

    private var statusDescription: String {
        if !authService.isAuthenticated {
            return Strings.Sync.signInToSync
        }

        switch syncManager.syncStatus {
        case .idle:
            if let lastSync = syncManager.lastSyncDate {
                return Strings.Sync.lastSynced(lastSyncText(lastSync))
            }
            return Strings.Sync.tapToSync
        case .syncing:
            return Strings.Sync.syncingData
        case .error(let message):
            return message
        case .offline:
            return Strings.Sync.noConnection
        }
    }

    private func lastSyncText(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 {
            return Strings.Sync.justNow.lowercased()
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return Strings.Sync.minutesAgoLong(minutes)
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return Strings.Sync.hoursAgo(hours)
        } else {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
    }
}

#Preview("Sync Status") {
    VStack(spacing: 20) {
        SyncStatusView()
        CompactSyncIndicator()
        SyncStatusButton()
            .padding()
    }
}
