//
//  StoryPageComposerView.swift
//  Linguista
//
//  Created by Daniel Grant on 10/30/26.
//

import SwiftUI

// Lets the reader describe the next page of the story, with an optional separate idea for its picture
struct StoryPageComposerView: View {
    @ObservedObject var viewModel: StoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var pageIdea = ""
    @State private var pictureContext = ""
    @FocusState private var focusedField: StoryInputField?

    private var language: String {
        viewModel.story?.language ?? ""
    }

    private var pageNumber: Int {
        (viewModel.story?.pages.count ?? 0) + 1
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What happens on this page?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)
                        TextField("e.g. The cat burns the first batch of croissants", text: $pageIdea, axis: .vertical)
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .idea)
                            .storyInputBackground()
                        Text("Write it in English or \(language). Leave it blank to let the story continue on its own.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)
                    }

                    StoryPictureContextField(
                        pictureContext: $pictureContext,
                        focusedField: $focusedField
                    )

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Button {
                        writePage()
                    } label: {
                        HStack(spacing: 6) {
                            if viewModel.isAddingPage {
                                ProgressView()
                                Text("Writing page…")
                            } else {
                                Image(systemName: "wand.and.stars")
                                Text("Write Page")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(viewModel.isAddingPage)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .top)
                // Sits behind the controls, so tapping empty space dismisses the keyboard
                .background {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { focusedField = nil }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Page \(pageNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(viewModel.isAddingPage)
                }
            }
            .tint(.brown)
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled(viewModel.isAddingPage)
        .onAppear { viewModel.errorMessage = nil }
    }

    private func writePage() {
        focusedField = nil
        Task {
            let added = await viewModel.addPage(idea: pageIdea, pictureContext: pictureContext)
            if added {
                dismiss()
            }
        }
    }
}

// MARK: - Shared Inputs

enum StoryInputField: Hashable {
    case idea
    case pictureContext
}

// An optional field describing what the page's picture should show, separate from its text
struct StoryPictureContextField: View {
    @Binding var pictureContext: String
    var focusedField: FocusState<StoryInputField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Picture context (optional)")
                .font(.caption)
                .foregroundColor(.secondary)
                .allowsHitTesting(false)
            TextField("e.g. Smoke pouring out of the oven", text: $pictureContext, axis: .vertical)
                .lineLimit(2...4)
                .focused(focusedField, equals: .pictureContext)
                .storyInputBackground()
            Text("Describe what the picture should show. Leave it blank to illustrate the text.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .allowsHitTesting(false)
        }
    }
}

extension View {
    // The rounded field background used by the story prompt and page composer
    func storyInputBackground() -> some View {
        padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
    }
}
