import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let note: Note?

    @State private var title: String = ""
    @State private var content: String = ""

    private var isNew: Bool { note == nil }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.deepBlack.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Title field
                    TextField("Title", text: $title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.primaryText)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    // Body editor
                    TextEditor(text: $content)
                        .scrollContentBackground(.hidden)
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.primaryText)
                        .padding(.horizontal, 16)
                        .overlay(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("Start writing...")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Theme.tertiaryText)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }
            .navigationTitle(isNew ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.deepBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.salmonAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(Theme.salmonAccent)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let note {
                    title = note.title
                    content = note.body
                }
            }
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }

        if let note {
            note.title = trimmedTitle
            note.body = content
            SyncManager.shared.markNeedsSync(note)
        } else {
            let newNote = Note(title: trimmedTitle, body: content, needsSync: true)
            modelContext.insert(newNote)
            try? modelContext.save()
            SyncManager.shared.markNeedsSync(newNote)
        }

        dismiss()
    }
}

#Preview {
    NoteEditorView(note: nil)
        .modelContainer(for: Note.self, inMemory: true)
}
