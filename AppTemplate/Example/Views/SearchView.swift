// EXAMPLE CODE — Replace with your own feature module.
// Delete the entire Example/ folder when building your own app.

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]
    @State private var searchText = ""

    private var filteredNotes: [Note] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return allNotes.filter { note in
            note.title.lowercased().contains(query) ||
            note.body.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.deepBlack.ignoresSafeArea()

                if searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.tertiaryText)

                        Text("Search your notes")
                            .font(.system(size: 17))
                            .foregroundStyle(Theme.secondaryText)
                    }
                } else if filteredNotes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.tertiaryText)

                        Text("No results for \"\(searchText)\"")
                            .font(.system(size: 17))
                            .foregroundStyle(Theme.secondaryText)
                    }
                } else {
                    List {
                        ForEach(filteredNotes) { note in
                            NavigationLink {
                                NoteDetailView(note: note)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.title.isEmpty ? "Untitled" : note.title)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Theme.primaryText)
                                        .lineLimit(1)

                                    Text(note.body)
                                        .font(.system(size: 13))
                                        .foregroundStyle(Theme.secondaryText)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 2)
                            }
                            .listRowBackground(Theme.cardBackground)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Theme.deepBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search notes...")
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: Note.self, inMemory: true)
}
