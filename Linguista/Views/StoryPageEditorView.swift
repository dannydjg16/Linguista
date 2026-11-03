//
//  StoryPageEditorView.swift
//  Linguista
//
//  Created by Daniel Grant on 10/31/26.
//

import SwiftUI

// Lets the reader change a page's text, its picture, or both.
// Picture changes only shape the illustration and never reach the text.
struct StoryPageEditorView: View {
    let pageID: UUID
    @ObservedObject var viewModel: StoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var textChange = ""
    @State private var pictureChange = ""
    @State private var redrawForNewText = true
    @FocusState private var focusedField: Field?

    private enum Field {
        case text, picture
    }

    private var page: StoryPage? {
        viewModel.story?.pages.first(where: { $0.id == pageID })
    }

    private var pageNumber: Int {
        (viewModel.story?.pages.firstIndex(where: { $0.id == pageID }) ?? 0) + 1
    }

    private var language: String {
        viewModel.story?.language ?? ""
    }

    private var isEditing: Bool {
        viewModel.editingPageIDs.contains(pageID)
    }

    private var hasTextChange: Bool {
        !textChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasPictureChange: Bool {
        !pictureChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let page {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Current text")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(page.text)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .storyInputBackground()
                                .textSelection(.enabled)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Change the text (optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)
                        TextField("e.g. Make the cat sound surprised", text: $textChange, axis: .vertical)
                            .lineLimit(2...5)
                            .focused($focusedField, equals: .text)
                            .storyInputBackground()
                        Text("Describe a change, or type the new text in \(language).")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)

                        if hasTextChange {
                            Toggle("Update the picture to match the new text", isOn: $redrawForNewText)
                                .font(.subheadline)
                                .tint(.brown)
                                .transition(.opacity)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Change the picture (optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)
                        TextField("e.g. Make it nighttime, with snow falling", text: $pictureChange, axis: .vertical)
                            .lineLimit(2...4)
                            .focused($focusedField, equals: .picture)
                            .storyInputBackground()
                        Text("Only changes the picture. The text stays as it is.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .allowsHitTesting(false)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    VStack(spacing: 12) {
                        Button {
                            applyChanges()
                        } label: {
                            HStack(spacing: 6) {
                                if isEditing {
                                    ProgressView()
                                    Text("Changing page…")
                                } else {
                                    Image(systemName: "wand.and.stars")
                                    Text("Apply Changes")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isEditing || (!hasTextChange && !hasPictureChange))

                        // Same prompt, new drawing, for when the picture just didn't come out well
                        Button {
                            viewModel.redrawImage(for: pageID)
                            dismiss()
                        } label: {
                            Label("Draw a New Picture", systemImage: "arrow.triangle.2.circlepath")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isEditing)
                    }
                    .controlSize(.large)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .top)
                // Sits behind the controls, so tapping empty space dismisses the keyboard
                .background {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { focusedField = nil }
                }
                .animation(.default, value: hasTextChange)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Edit Page \(pageNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isEditing)
                }
            }
            .tint(.brown)
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled(isEditing)
        .onAppear { viewModel.errorMessage = nil }
    }

    private func applyChanges() {
        focusedField = nil
        Task {
            let applied = await viewModel.editPage(pageID, textChange: textChange, pictureChange: pictureChange,
                                                   redrawForNewText: redrawForNewText)
            if applied {
                dismiss()
            }
        }
    }
}
