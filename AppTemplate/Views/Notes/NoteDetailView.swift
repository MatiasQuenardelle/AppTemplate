import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @State private var showEditor = false

    var body: some View {
        ZStack {
            Theme.deepBlack.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(note.title.isEmpty ? "Untitled" : note.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.primaryText)

                    HStack(spacing: 12) {
                        Label(note.createdAt.shortDate, systemImage: "calendar")
                        if note.updatedAt != note.createdAt {
                            Label("Edited \(note.updatedAt.shortDate)", systemImage: "pencil")
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.tertiaryText)

                    Divider()
                        .background(Theme.tertiaryText.opacity(0.3))

                    Text(note.body.isEmpty ? "No content" : note.body)
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.primaryText.opacity(note.body.isEmpty ? 0.5 : 1))
                        .lineSpacing(4)
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.deepBlack, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditor = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(Theme.copperGold)
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            NoteEditorView(note: note)
        }
    }
}
