//
//  StoryLibraryView.swift
//  Linguista
//
//  Created by Daniel Grant on 10/30/26.
//

import SwiftUI
import CoreData

struct StoryLibraryView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.savedAt, order: .reverse)])
    private var savedStories: FetchedResults<SavedStory>

    var body: some View {
        Group {
            if savedStories.isEmpty {
                ContentUnavailableView(
                    "No Saved Stories",
                    systemImage: "books.vertical",
                    description: Text("Tap the bookmark while reading a story to keep it here.")
                )
            } else {
                List {
                    ForEach(savedStories) { savedStory in
                        NavigationLink {
                            SavedStoryReaderView(story: StoryLibraryService.story(from: savedStory))
                        } label: {
                            SavedStoryRow(savedStory: savedStory)
                        }
                    }
                    .onDelete(perform: deleteStories)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("My Stories")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deleteStories(at offsets: IndexSet) {
        let storyLibrary = StoryLibraryService()
        offsets.map { savedStories[$0] }.forEach(storyLibrary.delete)
    }
}

// MARK: - Saved Story Row

private struct SavedStoryRow: View {
    @ObservedObject var savedStory: SavedStory

    private var pages: [SavedStoryPage] {
        ((savedStory.pages as? Set<SavedStoryPage>) ?? []).sorted { $0.index < $1.index }
    }

    // The first illustrated page stands in as the cover
    private var coverImage: UIImage? {
        pages.lazy.compactMap { $0.imageData.flatMap(UIImage.init(data:)) }.first
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .secondarySystemBackground))
                .frame(width: 72, height: 48)
                .overlay {
                    if let coverImage {
                        Image(uiImage: coverImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "book.closed")
                            .foregroundColor(.brown)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(savedStory.title ?? "")
                    .font(.headline)
                    .lineLimit(1)
                Text(savedStory.titleTranslation ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text("\(savedStory.language ?? "") · \(savedStory.level ?? "") · \(pages.count) pages")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Saved Story Reader

struct SavedStoryReaderView: View {
    @StateObject private var viewModel: StoryViewModel

    init(story: Story) {
        _viewModel = StateObject(wrappedValue: StoryViewModel(savedStory: story))
    }

    var body: some View {
        StoryReaderView(viewModel: viewModel)
            .navigationTitle("Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    StorySaveButton(viewModel: viewModel)
                    StoryTranslationButton(viewModel: viewModel)
                }
            }
    }
}
