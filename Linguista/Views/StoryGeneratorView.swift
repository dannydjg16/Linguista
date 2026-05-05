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
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color("1a0a2e"), Color("2d1b4e"), Color("1a2744")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if viewModel.storyStarted {
                    StoryPageView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    StoryPromptView(viewModel: viewModel)
                        .transition(.opacity)
                }
            }
            .navigationTitle("Create a Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if viewModel.storyStarted {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.storyStarted = false
                                viewModel.pages = []
                                viewModel.currentIndex = -1
                                viewModel.promptText = ""
                            }
                        }) {
                            Label("New Story", systemImage: "book.closed")
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
