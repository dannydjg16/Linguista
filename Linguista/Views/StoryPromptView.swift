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
    @FocusState private var focusedField: StoryInputField?

    private var language: String {
        Utilities.getLanguageName(by: accountManager.languageToLearn)
    }

    private var isPageByPage: Bool {
        viewModel.creationMode == .pageByPage
    }

    private var modeDescription: String {
        switch viewModel.creationMode {
        case .wholeStory: return "Give an idea and the whole story is written for you."
        case .pageByPage: return "Describe each page yourself, one at a time."
        case .allAtOnce: return "Plan every page and its picture, then create the whole book at once."
        }
    }

    private var hasPrompt: Bool {
        !viewModel.promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        GeometryReader { proxy in
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
                    // Lets taps on the header fall through to dismiss the keyboard
                    .allowsHitTesting(false)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Level")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)
                        Picker("Level", selection: $viewModel.level) {
                            ForEach(StoryLevel.allCases) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to write it")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)
                        Picker("How to write it", selection: $viewModel.creationMode.animation()) {
                            ForEach(StoryCreationMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        Text(modeDescription)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title (optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)
                        TextField("e.g. The Bakery Cat", text: $viewModel.customTitleText)
                            .focused($focusedField, equals: .title)
                            .submitLabel(.done)
                            .storyInputBackground()
                        Text("Write it in English or \(language). Leave it blank to have one made up for you.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)
                    }

                    if viewModel.creationMode == .allAtOnce {
                        StoryBookBuilderView(viewModel: viewModel, language: language, focusedField: $focusedField)
                            .transition(.opacity)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(isPageByPage ? "What happens on the first page?" : "What should the story be about?")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .allowsHitTesting(false)
                            TextField(isPageByPage ? "e.g. A cat opens a tiny bakery in Paris" : "e.g. A cat who opens a bakery in Paris",
                                      text: $viewModel.promptText, axis: .vertical)
                                .lineLimit(3...6)
                                .focused($focusedField, equals: .idea)
                                .storyInputBackground()
                        }

                        if isPageByPage {
                            StoryPictureContextField(
                                pictureContext: $viewModel.pictureContextText,
                                focusedField: $focusedField
                            )
                            .transition(.opacity)
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
                                Text(isPageByPage ? "Writing your first page…" : "Writing your story…")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            VStack(spacing: 12) {
                                Button {
                                    startStory(surpriseMe: false)
                                } label: {
                                    Label(isPageByPage ? "Write First Page" : "Write My Story", systemImage: "wand.and.stars")
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
                }
                .padding()
                // Fills the screen so tapping the empty space below the buttons also dismisses the keyboard
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .top)
                // Sits behind the controls, so the text field, picker, and buttons still get their own taps
                .background {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { focusedField = nil }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        // An error from one mode doesn't apply to the others
        .onChange(of: viewModel.creationMode) { viewModel.errorMessage = nil }
    }

    private func startStory(surpriseMe: Bool) {
        focusedField = nil
        Task {
            await viewModel.generateStory(language: language, surpriseMe: surpriseMe)
        }
    }
}
