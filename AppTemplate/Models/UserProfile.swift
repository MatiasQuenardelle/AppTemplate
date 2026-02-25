import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var needsSync: Bool
    var hasCompletedOnboarding: Bool

    init(
        id: UUID = UUID(),
        name: String = "User",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        needsSync: Bool = false,
        hasCompletedOnboarding: Bool = false
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.needsSync = needsSync
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
