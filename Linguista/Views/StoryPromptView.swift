//
//  StoryPromptView.swift
//  Linguista
//
//  Created by Daniel Grant on 5/4/26.
//

import SwiftUI

struct StoryPromptView: View {
    @ObservedObject var viewModel: StoryViewModel
    @EnvironmentObject var accountManager: AccountManager
    @FocusState private var isPromptFocused: Bool

    private var language: String {
        Utilities.getLanguageName(by: accountManager.languageToLearn)
    }

    private var hasPrompt: Bool {
        !viewModel.promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "book.pages")
                        .font(.system(size: 44))
                        .foregroundColor(.brown)
                    Text("Read a story in \(language)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    Text("Every page is illustrated. Tap any word to see what it means.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Level", selection: $viewModel.level) {
                        ForEach(StoryLevel.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("What should the story be about?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("e.g. A cat who opens a bakery in Paris", text: $viewModel.promptText, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($isPromptFocused)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: .secondarySystemBackground))
                        )
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                if viewModel.isGeneratingStory {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Writing your story…")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(spacing: 12) {
                        Button {
                            startStory(surpriseMe: false)
                        } label: {
                            Label("Write My Story", systemImage: "wand.and.stars")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!hasPrompt)

                        Button {
                            startStory(surpriseMe: true)
                        } label: {
                            Label("Surprise Me", systemImage: "dice")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .controlSize(.large)
                    .tint(.brown)
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func startStory(surpriseMe: Bool) {
        isPromptFocused = false
        Task {
            await viewModel.generateStory(language: language, surpriseMe: surpriseMe)
        }
    }
}
