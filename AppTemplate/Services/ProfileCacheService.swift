import Foundation
import SwiftUI
import SwiftData

/// Centralized service for caching the user profile.
/// Eliminates the need for `@Query private var profiles: [UserProfile]` in every view,
/// which prevents cascade re-renders on any SwiftData change.
@MainActor
@Observable
final class ProfileCacheService {
    static let shared = ProfileCacheService()

    private(set) var currentProfile: UserProfile?
    private(set) var isInitialized: Bool = false

    private var modelContainer: ModelContainer?
    private var lastFetchTime: Date?
    private let cacheDuration: TimeInterval = 5.0

    private init() {}

    // MARK: - Configuration

    func configure(with container: ModelContainer) {
        self.modelContainer = container

        let context = ModelContext(container)
        var descriptor = FetchDescriptor<UserProfile>()
        descriptor.fetchLimit = 1

        if let profiles = try? context.fetch(descriptor) {
            if let existingProfile = profiles.first {
                self.currentProfile = existingProfile
            } else {
                let defaultProfile = UserProfile(name: "User")
                context.insert(defaultProfile)
                try? context.save()
                self.currentProfile = defaultProfile
            }
            self.lastFetchTime = Date()
        }

        isInitialized = true
    }

    // MARK: - Refresh

    func refresh(force: Bool = false) {
        guard let container = modelContainer else { return }

        if !force, let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheDuration {
            return
        }

        let context = ModelContext(container)
        var descriptor = FetchDescriptor<UserProfile>()
        descriptor.fetchLimit = 1

        if let profiles = try? context.fetch(descriptor) {
            self.currentProfile = profiles.first
            self.lastFetchTime = Date()
            self.isInitialized = true
        }
    }

    func invalidate() {
        lastFetchTime = nil
        refresh(force: true)
    }

    func updateCachedProfile(_ profile: UserProfile?) {
        currentProfile = profile
        lastFetchTime = Date()
        isInitialized = true
    }

    // MARK: - Convenience Accessors

    var name: String {
        currentProfile?.name ?? "User"
    }
}
