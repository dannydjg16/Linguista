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
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation { viewModel.showTranslation.toggle() }
                        } label: {
                            Label(viewModel.showTranslation ? "Hide Translation" : "Show Translation",
                                  systemImage: viewModel.showTranslation ? "character.bubble.fill" : "character.bubble")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Story Reader

struct StoryReaderView: View {
    @ObservedObject var viewModel: StoryViewModel

    var body: some View {
        if let story = viewModel.story {
            VStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text(story.title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    if viewModel.showTranslation {
                        Text(story.titleTranslation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("Page \(viewModel.currentPageIndex + 1) of \(story.pages.count)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
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
        }
    }
}

// MARK: - Navigation Controls

struct StoryNavigationControls: View {
    @ObservedObject var viewModel: StoryViewModel

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { viewModel.goToPreviousPage() }
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.currentPageIndex == 0)

            if viewModel.isOnLastPage {
                Button {
                    Task { await viewModel.continueStory() }
                } label: {
                    HStack(spacing: 6) {
                        if viewModel.isContinuingStory {
                            ProgressView()
                        } else {
                            Image(systemName: "wand.and.stars")
                            Text("Keep Going")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isContinuingStory)
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
    }
}

#Preview {
    StoryGeneratorView()
        .environmentObject(ConversationViewModel())
        .environmentObject(AccountManager(context: PersistenceController.shared.container.viewContext))
}
