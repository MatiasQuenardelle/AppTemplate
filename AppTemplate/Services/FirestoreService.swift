import Foundation
import FirebaseFirestore

// MARK: - Firestore Service

actor FirestoreService {
    static let shared = FirestoreService()

    private var db: Firestore { Firestore.firestore() }
    private var isConfigured = false

    private init() {}

    // MARK: - Configuration

    /// Configure Firestore settings. MUST be called before any Firestore operations.
    /// Called from AppDelegate after Firebase.configure().
    nonisolated func configureSync() {
        let settings = Firestore.firestore().settings
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        Firestore.firestore().settings = settings
    }

    // MARK: - User Profile

    func saveProfile(_ profile: FSUserProfile, userId: String) async throws {
        let ref = db.collection("users").document(userId).collection("profile").document("data")
        try ref.setData(from: profile, merge: true)
    }

    func fetchProfile(userId: String) async throws -> FSUserProfile? {
        let ref = db.collection("users").document(userId).collection("profile").document("data")
        let snapshot = try await ref.getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: FSUserProfile.self)
    }

    // MARK: - Notes

    func saveNote(_ note: FSNote, userId: String) async throws {
        let ref = db.collection("users").document(userId).collection("notes").document(note.id)
        try ref.setData(from: note, merge: true)
    }

    func fetchNotes(userId: String) async throws -> [FSNote] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("notes")
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: FSNote.self) }
    }

    func deleteNote(noteId: String, userId: String) async throws {
        try await db.collection("users").document(userId)
            .collection("notes").document(noteId)
            .delete()
    }

    // MARK: - Bug Reports

    func saveBugReport(_ report: FSBugReport) async throws {
        let ref = db.collection("bugReports").document(report.id)
        try ref.setData(from: report)
    }

    // MARK: - Listeners

    func addNotesListener(
        userId: String,
        onChange: @escaping @Sendable ([FSNote]) -> Void
    ) -> ListenerRegistration {
        db.collection("users").document(userId)
            .collection("notes")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let notes = documents.compactMap { try? $0.data(as: FSNote.self) }
                onChange(notes)
            }
    }

    func addProfileListener(
        userId: String,
        onChange: @escaping @Sendable (FSUserProfile?) -> Void
    ) -> ListenerRegistration {
        db.collection("users").document(userId)
            .collection("profile").document("data")
            .addSnapshotListener { snapshot, error in
                guard let snapshot else { return }
                let profile = try? snapshot.data(as: FSUserProfile.self)
                onChange(profile)
            }
    }

    // MARK: - Delete All User Data

    func deleteAllUserData(userId: String) async throws {
        let userRef = db.collection("users").document(userId)

        // Delete notes
        let notes = try await userRef.collection("notes").getDocuments()
        for doc in notes.documents {
            try await doc.reference.delete()
        }

        // Delete profile
        try await userRef.collection("profile").document("data").delete()

        // Delete user document
        try await userRef.delete()
    }
}
