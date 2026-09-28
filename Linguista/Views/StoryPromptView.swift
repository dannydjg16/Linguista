//
//  StoryPromptView.swift
//  Linguista
//
//  Created by Daniel Grant on 5/4/26.
//

import SwiftUI

struct StoryPromptView: View {
    @ObservedObject var viewModel: StoryViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                    )
                    .symbolEffect(.pulse)

                Text("Create a story prompt\nto get your story started")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("Describe a character, a place, or a feeling — let imagination do the rest.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Prompt input
            VStack(alignment: .leading, spacing: 8) {
                Text("Your prompt")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.leading, 4)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isFocused ? Color.purple.opacity(0.6) : Color.white.opacity(0.15), lineWidth: 1)
                        )

                    if viewModel.promptText.isEmpty {
                        Text("e.g. A young inventor who finds a map in her grandmother's attic…")
                            .foregroundStyle(.white.opacity(0.3))
                            .font(.system(size: 15, design: .rounded))
                            .padding(16)
                    }

                    TextEditor(text: $viewModel.promptText)
                        .focused($isFocused)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(.white)
                        .font(.system(size: 15, design: .rounded))
                        .frame(minHeight: 100, maxHeight: 150)
                        .padding(12)
                }
            }
            .padding(.horizontal)

            // Error message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.8))
                    .padding(.horizontal)
            }

            // Start button
            Button {
                isFocused = false
                Task {
                    withAnimation(.spring()) {
                        _ = viewModel.isLoading
                    }
                    await viewModel.startStory()
                }
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "wand.and.stars")
                        Text("Begin the Story")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(colors: [Color("7b2fff"), Color("3b82f6")],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .purple.opacity(0.5), radius: 12, y: 4)
            }
            .disabled(viewModel.isLoading || viewModel.promptText.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal)
            .animation(.spring(), value: viewModel.isLoading)

            Spacer()
        }
    }
}
