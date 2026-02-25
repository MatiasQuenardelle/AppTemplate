import Foundation

// MARK: - Firestore Document Protocol

protocol FirestoreDocument: Codable {
    var id: String { get }
    var updatedAt: Date { get }
}

// MARK: - FSUserProfile

struct FSUserProfile: FirestoreDocument {
    let id: String
    let name: String
    let hasCompletedOnboarding: Bool
    let createdAt: Date
    let updatedAt: Date

    init(from profile: UserProfile) {
        self.id = profile.id.uuidString
        self.name = profile.name
        self.hasCompletedOnboarding = profile.hasCompletedOnboarding
        self.createdAt = profile.createdAt
        self.updatedAt = profile.updatedAt
    }

    func applyTo(_ profile: UserProfile) {
        profile.name = name
        profile.hasCompletedOnboarding = hasCompletedOnboarding
        profile.updatedAt = updatedAt
        profile.needsSync = false
    }
}

// MARK: - EXAMPLE: FSNote — Delete this struct when removing the Example module.

struct FSNote: FirestoreDocument {
    let id: String
    let title: String
    let body: String
    let createdAt: Date
    let updatedAt: Date

    init(from note: Note) {
        self.id = note.id.uuidString
        self.title = note.title
        self.body = note.body
        self.createdAt = note.createdAt
        self.updatedAt = note.updatedAt
    }

    func toNote() -> Note {
        Note(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            body: body,
            createdAt: createdAt,
            updatedAt: updatedAt,
            needsSync: false
        )
    }

    func applyTo(_ note: Note) {
        note.title = title
        note.body = body
        note.updatedAt = updatedAt
        note.needsSync = false
    }
}

// MARK: - FSBugReport

struct FSBugReport: FirestoreDocument {
    let id: String
    let userId: String
    let description: String
    let imageURL: String?
    let appVersion: String
    let iosVersion: String
    let deviceModel: String
    let locale: String
    let status: String
    let createdAt: Date
    var updatedAt: Date { createdAt }
}
