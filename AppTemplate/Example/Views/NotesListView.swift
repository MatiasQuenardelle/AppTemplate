// EXAMPLE CODE — Replace with your own feature module.
// Delete the entire Example/ folder when building your own app.

import SwiftUI
import SwiftData

struct NotesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]
    @State private var showNewNote = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.deepBlack.ignoresSafeArea()

                if notes.isEmpty {
                    emptyState
                } else {
                    notesList
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Theme.deepBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CompactSyncIndicator()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewNote = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.copperGold)
                    }
                }
            }
            .sheet(isPresented: $showNewNote) {
                NoteEditorView(note: nil)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "note.text")
                .font(.system(size: 56))
                .foregroundStyle(Theme.tertiaryText)

            Text("No Notes Yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.primaryText)

            Text("Tap + to create your first note")
                .font(.system(size: 15))
                .foregroundStyle(Theme.secondaryText)
        }
    }

    private var notesList: some View {
        List {
            ForEach(notes) { note in
                NavigationLink {
                    NoteDetailView(note: note)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(note.title.isEmpty ? "Untitled" : note.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.primaryText)
                            .lineLimit(1)

                        Text(note.body.isEmpty ? "No content" : note.body)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.secondaryText)
                            .lineLimit(2)

                        Text(note.updatedAt.shortDate)
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.tertiaryText)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Theme.cardBackground)
            }
            .onDelete(perform: deleteNotes)
        }
        .scrollContentBackground(.hidden)
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            Task {
                await SyncManager.shared.deleteNoteFromCloud(note)
            }
            modelContext.delete(note)
        }
        try? modelContext.save()
    }
}

#Preview {
    NotesListView()
        .modelContainer(for: Note.self, inMemory: true)
}
