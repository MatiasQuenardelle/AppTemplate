import Foundation
import SwiftData
import FirebaseFirestore

// MARK: - Sync Status

enum SyncStatus: Equatable {
    case idle
    case syncing
    case error(String)
    case offline

    var isActive: Bool {
        if case .syncing = self { return true }
        return false
    }
}

// MARK: - Sync Manager

@MainActor @Observable
final class SyncManager {
    static let shared = SyncManager()

    private(set) var syncStatus: SyncStatus = .idle
    private(set) var lastSyncDate: Date?
    private(set) var pendingChangesCount: Int = 0
    var showSyncAlert = false

    private var userId: String?
    private var modelContext: ModelContext?
    private var listeners: [ListenerRegistration] = []
    private var syncTask: Task<Void, Never>?
    private var debounceTask: Task<Void, Never>?

    private init() {}

    // MARK: - Configuration

    func configure(userId: String, modelContext: ModelContext) async {
        self.userId = userId
        self.modelContext = modelContext

        let hasCompletedInitialSync = UserDefaults.standard.bool(forKey: "hasCompletedInitialSync_\(userId)")

        if !hasCompletedInitialSync {
            await performInitialSync()
        } else {
            await syncPendingChanges()
        }

        setupListeners()
    }

    func configureWithErrorHandling(userId: String, modelContext: ModelContext) async throws {
        self.userId = userId
        self.modelContext = modelContext

        let hasCompletedInitialSync = UserDefaults.standard.bool(forKey: "hasCompletedInitialSync_\(userId)")

        if !hasCompletedInitialSync {
            await performInitialSync()
        } else {
            await syncPendingChanges()
        }

        setupListeners()
    }

    // MARK: - Initial Sync (Download All)

    private func performInitialSync() async {
        guard let userId, let modelContext else { return }
        syncStatus = .syncing

        do {
            // Download profile
            if let fsProfile = try await FirestoreService.shared.fetchProfile(userId: userId) {
                var descriptor = FetchDescriptor<UserProfile>()
                descriptor.fetchLimit = 1
                let existingProfiles = (try? modelContext.fetch(descriptor)) ?? []

                if let existing = existingProfiles.first {
                    fsProfile.applyTo(existing)
                } else {
                    let profile = UserProfile(
                        id: UUID(uuidString: fsProfile.id) ?? UUID(),
                        name: fsProfile.name,
                        hasCompletedOnboarding: fsProfile.hasCompletedOnboarding
                    )
                    profile.needsSync = false
                    modelContext.insert(profile)
                }
            }

            // Download notes
            let fsNotes = try await FirestoreService.shared.fetchNotes(userId: userId)
            let existingNotes = (try? modelContext.fetch(FetchDescriptor<Note>())) ?? []
            let existingNoteIds = Set(existingNotes.map { $0.id.uuidString })

            for fsNote in fsNotes {
                if let existing = existingNotes.first(where: { $0.id.uuidString == fsNote.id }) {
                    if fsNote.updatedAt > existing.updatedAt {
                        fsNote.applyTo(existing)
                    }
                } else {
                    let note = fsNote.toNote()
                    modelContext.insert(note)
                }
            }

            try? modelContext.save()

            UserDefaults.standard.set(true, forKey: "hasCompletedInitialSync_\(userId)")
            lastSyncDate = Date()
            syncStatus = .idle

            NotificationCenter.default.post(name: .cloudSyncCompleted, object: nil)
        } catch {
            syncStatus = .error("Sync failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Sync Pending Changes (Upload)

    func syncPendingChanges() async {
        guard let userId, let modelContext else { return }

        do {
            // Sync profile
            var profileDescriptor = FetchDescriptor<UserProfile>(
                predicate: #Predicate<UserProfile> { $0.needsSync == true }
            )
            profileDescriptor.fetchLimit = 1

            if let profile = try modelContext.fetch(profileDescriptor).first {
                let fsProfile = FSUserProfile(from: profile)
                try await FirestoreService.shared.saveProfile(fsProfile, userId: userId)
                profile.needsSync = false
                try? modelContext.save()
            }

            // Sync notes
            let noteDescriptor = FetchDescriptor<Note>(
                predicate: #Predicate<Note> { $0.needsSync == true }
            )

            let pendingNotes = (try? modelContext.fetch(noteDescriptor)) ?? []
            for note in pendingNotes {
                let fsNote = FSNote(from: note)
                try await FirestoreService.shared.saveNote(fsNote, userId: userId)
                note.needsSync = false
            }
            try? modelContext.save()

            pendingChangesCount = 0
            lastSyncDate = Date()
        } catch {
            print("[SyncManager] syncPendingChanges error: \(error)")
        }
    }

    // MARK: - Sync All

    func syncAll() async {
        syncStatus = .syncing
        await syncPendingChanges()
        syncStatus = .idle
    }

    // MARK: - Mark Needs Sync

    /// Call this from views after modifying a model object.
    /// Explicitly saves the context to ensure cross-context visibility.
    func markNeedsSync<T: AnyObject>(_ object: T) where T: AnyObject {
        if let note = object as? Note {
            note.needsSync = true
            note.updatedAt = Date()
            note.modelContext?.save(withAutosaving: true)
        } else if let profile = object as? UserProfile {
            profile.needsSync = true
            profile.updatedAt = Date()
            profile.modelContext?.save(withAutosaving: true)
        }

        pendingChangesCount += 1
        scheduleDebouncedSync()
    }

    private func scheduleDebouncedSync() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second debounce
            guard !Task.isCancelled else { return }
            await syncPendingChanges()
        }
    }

    // MARK: - Listeners

    private func setupListeners() {
        guard let userId, let modelContext else { return }
        stopListening()

        // Notes listener
        let notesListener = FirestoreService.shared.addNotesListener(userId: userId) { [weak self] fsNotes in
            Task { @MainActor [weak self] in
                self?.handleRemoteNotes(fsNotes)
            }
        }
        listeners.append(notesListener)

        // Profile listener
        let profileListener = FirestoreService.shared.addProfileListener(userId: userId) { [weak self] fsProfile in
            Task { @MainActor [weak self] in
                if let fsProfile {
                    self?.handleRemoteProfile(fsProfile)
                }
            }
        }
        listeners.append(profileListener)
    }

    private func handleRemoteNotes(_ fsNotes: [FSNote]) {
        guard let modelContext else { return }
        let existingNotes = (try? modelContext.fetch(FetchDescriptor<Note>())) ?? []

        for fsNote in fsNotes {
            if let existing = existingNotes.first(where: { $0.id.uuidString == fsNote.id }) {
                if fsNote.updatedAt > existing.updatedAt && !existing.needsSync {
                    fsNote.applyTo(existing)
                }
            } else {
                let note = fsNote.toNote()
                modelContext.insert(note)
            }
        }
        try? modelContext.save()
    }

    private func handleRemoteProfile(_ fsProfile: FSUserProfile) {
        guard let modelContext else { return }
        var descriptor = FetchDescriptor<UserProfile>()
        descriptor.fetchLimit = 1

        guard let profile = try? modelContext.fetch(descriptor).first else { return }
        if fsProfile.updatedAt > profile.updatedAt && !profile.needsSync {
            fsProfile.applyTo(profile)
            try? modelContext.save()
            ProfileCacheService.shared.invalidate()
        }
    }

    func stopListening() {
        for listener in listeners {
            listener.remove()
        }
        listeners.removeAll()
        debounceTask?.cancel()
        syncTask?.cancel()
    }

    // MARK: - Delete Note from Cloud

    func deleteNoteFromCloud(_ note: Note) async {
        guard let userId else { return }
        do {
            try await FirestoreService.shared.deleteNote(noteId: note.id.uuidString, userId: userId)
        } catch {
            print("[SyncManager] deleteNoteFromCloud error: \(error)")
        }
    }
}

// MARK: - ModelContext Helper

private extension ModelContext {
    func save(withAutosaving: Bool) {
        do {
            try save()
        } catch {
            print("[ModelContext] save error: \(error)")
        }
    }
}
