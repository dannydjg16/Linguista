//
//  StoryGeneratorView.swift
//  Linguista
//
//  Created by Daniel Grant on 5/4/26.
//

import SwiftUI

struct StoryGeneratorView: View {
    @StateObject private var viewModel = StoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.story != nil {
                    StoryReaderView(viewModel: viewModel)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    StoryPromptView(viewModel: viewModel)
                        .transition(.opacity)
                }
            }
            .navigationTitle(viewModel.story == nil ? "Create a Story" : "Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.story != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation { viewModel.reset() }
                        } label: {
                            Label("New Story", systemImage: "square.and.pencil")
                        }
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        StorySaveButton(viewModel: viewModel)
                        StoryTranslationButton(viewModel: viewModel)
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            StoryLibraryView()
                        } label: {
                            Label("My Stories", systemImage: "books.vertical")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Toolbar Buttons

struct StorySaveButton: View {
    @ObservedObject var viewModel: StoryViewModel

    var body: some View {
        Button {
            viewModel.toggleSaved()
        } label: {
            Label(viewModel.isSaved ? "Remove from My Stories" : "Save to My Stories",
                  systemImage: viewModel.isSaved ? "bookmark.fill" : "bookmark")
        }
    }
}

struct StoryTranslationButton: View {
    @ObservedObject var viewModel: StoryViewModel

    var body: some View {
        Button {
            withAnimation { viewModel.showTranslation.toggle() }
        } label: {
            Label(viewModel.showTranslation ? "Hide Translation" : "Show Translation",
                  systemImage: viewModel.showTranslation ? "character.bubble.fill" : "character.bubble")
        }
    }
}

// MARK: - Story Reader

struct StoryReaderView: View {
    @ObservedObject var viewModel: StoryViewModel
    @State private var showDeleteConfirmation = false
    @State private var showRenameAlert = false
    @State private var newTitle = ""

    var body: some View {
        if let story = viewModel.story {
            VStack(spacing: 0) {
                VStack(spacing: 2) {
                    // Tap the title to rename the story
                    Button {
                        newTitle = story.title
                        showRenameAlert = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(story.title)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            if viewModel.isRenamingStory {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "pencil")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isRenamingStory)
                    .accessibilityHint("Renames the story")
                    .alert("Rename Story", isPresented: $showRenameAlert) {
                        TextField("Title", text: $newTitle)
                        Button("Cancel", role: .cancel) {}
                        Button("Rename") {
                            Task { await viewModel.renameStory(to: newTitle) }
                        }
                    } message: {
                        Text("Write it in English or \(story.language).")
                    }
                    if viewModel.showTranslation {
                        Text(story.titleTranslation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 6) {
                        Text("Page \(viewModel.currentPageIndex + 1) of \(story.pages.count)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                        }
                        .accessibilityLabel("Delete Page")
                        .foregroundColor(viewModel.canDeleteCurrentPage ? .red : .secondary)
                        .disabled(!viewModel.canDeleteCurrentPage)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                TabView(selection: $viewModel.currentPageIndex) {
                    ForEach(Array(story.pages.enumerated()), id: \.element.id) { index, page in
                        StoryPageView(page: page, viewModel: viewModel)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: viewModel.currentPageIndex) { _, newIndex in
                    viewModel.loadImages(around: newIndex)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Divider()

                StoryNavigationControls(viewModel: viewModel)
                    .padding()
            }
            .confirmationDialog(
                "Delete page \(viewModel.currentPageIndex + 1)?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Page", role: .destructive) {
                    viewModel.deleteCurrentPage()
                }
            } message: {
                Text(viewModel.isSaved
                     ? "Its text, picture, and audio will also be removed from My Stories."
                     : "Its text, picture, and audio will be removed.")
            }
        }
    }
}

// MARK: - Navigation Controls

struct StoryNavigationControls: View {
    @ObservedObject var viewModel: StoryViewModel
    @State private var showPageComposer = false

    private var isWriting: Bool {
        viewModel.isContinuingStory || viewModel.isAddingPage
    }

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { viewModel.goToPreviousPage() }
            } label: {
                // Shrinks to an arrow on the last page to make room for both ways of continuing
                if viewModel.isOnLastPage {
                    Image(systemName: "chevron.left")
                        .accessibilityLabel("Back")
                } else {
                    Label("Back", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.currentPageIndex == 0)

            if viewModel.isOnLastPage {
                // Write the next page yourself
                Button {
                    showPageComposer = true
                } label: {
                    Group {
                        if viewModel.isAddingPage {
                            ProgressView()
                        } else {
                            Text("Add Page")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isWriting)

                // Let the story write several more pages on its own
                Button {
                    Task { await viewModel.continueStory() }
                } label: {
                    Group {
                        if viewModel.isContinuingStory {
                            ProgressView()
                        } else {
                            Text("Keep Going")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isWriting)
            } else {
                Button {
                    withAnimation { viewModel.goToNextPage() }
                } label: {
                    HStack(spacing: 6) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .controlSize(.large)
        .tint(.brown)
        .sheet(isPresented: $showPageComposer) {
            StoryPageComposerView(viewModel: viewModel)
        }
    }
}

#Preview {
    StoryGeneratorView()
        .environmentObject(ConversationViewModel())
        .environmentObject(AccountManager(context: PersistenceController.shared.container.viewContext))
}
