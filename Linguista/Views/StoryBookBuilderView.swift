//
//  StoryBookBuilderView.swift
//  Linguista
//
//  Created by Daniel Grant on 10/31/26.
//

import SwiftUI

// Lets the reader plan every page of a book, each with its own text idea and picture context,
// then write the whole book at once
struct StoryBookBuilderView: View {
    @ObservedObject var viewModel: StoryViewModel
    let language: String
    var focusedField: FocusState<StoryInputField?>.Binding

    // One request writes the whole book, so keep it within what the model can answer in one go
    static let maxPages = 20

    private var plannedPageCount: Int {
        viewModel.pageDrafts.filter { !$0.isEmpty }.count
    }

    private var canCreate: Bool {
        viewModel.pageDrafts.contains(where: \.hasIdea)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Plan each page: what happens in it, and optionally what its picture should show. Picture context only shapes the illustration, never the text.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .allowsHitTesting(false)

            ForEach(Array(viewModel.pageDrafts.enumerated()), id: \.element.id) { index, draft in
                if let binding = binding(for: draft.id) {
                    StoryPageDraftCard(
                        pageNumber: index + 1,
                        draft: binding,
                        language: language,
                        canMoveUp: index > 0,
                        canMoveDown: index < viewModel.pageDrafts.count - 1,
                        canDelete: viewModel.pageDrafts.count > 1,
                        focusedField: focusedField,
                        onMove: { offset in move(draft.id, by: offset) },
                        onDelete: { delete(draft.id) }
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            Button {
                addPage()
            } label: {
                Label("Add Page", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(viewModel.pageDrafts.count >= Self.maxPages || viewModel.isGeneratingStory)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }

            if viewModel.isGeneratingStory {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Writing your book…")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                Button {
                    createBook()
                } label: {
                    Label(plannedPageCount == 1 ? "Create Book (1 page)" : "Create Book (\(plannedPageCount) pages)",
                          systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!canCreate)
            }
        }
        .tint(.brown)
    }

    // MARK: - Editing

    private func binding(for id: UUID) -> Binding<StoryPageDraft>? {
        guard viewModel.pageDrafts.contains(where: { $0.id == id }) else { return nil }
        return Binding(
            get: { viewModel.pageDrafts.first(where: { $0.id == id }) ?? StoryPageDraft(id: id) },
            set: { newValue in
                if let index = viewModel.pageDrafts.firstIndex(where: { $0.id == id }) {
                    viewModel.pageDrafts[index] = newValue
                }
            }
        )
    }

    private func addPage() {
        let draft = StoryPageDraft()
        withAnimation { viewModel.pageDrafts.append(draft) }
        focusedField.wrappedValue = .pageIdea(draft.id)
    }

    private func move(_ id: UUID, by offset: Int) {
        guard let index = viewModel.pageDrafts.firstIndex(where: { $0.id == id }) else { return }
        let destination = index + offset
        guard viewModel.pageDrafts.indices.contains(destination) else { return }
        withAnimation { viewModel.pageDrafts.swapAt(index, destination) }
    }

    private func delete(_ id: UUID) {
        guard viewModel.pageDrafts.count > 1 else { return }
        focusedField.wrappedValue = nil
        withAnimation { viewModel.pageDrafts.removeAll { $0.id == id } }
    }

    private func createBook() {
        focusedField.wrappedValue = nil
        Task {
            await viewModel.generateBook(language: language)
        }
    }
}

// MARK: - Page Card

struct StoryPageDraftCard: View {
    let pageNumber: Int
    @Binding var draft: StoryPageDraft
    let language: String
    let canMoveUp: Bool
    let canMoveDown: Bool
    let canDelete: Bool
    var focusedField: FocusState<StoryInputField?>.Binding
    let onMove: (Int) -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Page \(pageNumber)")
                    .font(.headline)
                Spacer()
                Menu {
                    Button { onMove(-1) } label: { Label("Move Up", systemImage: "arrow.up") }
                        .disabled(!canMoveUp)
                    Button { onMove(1) } label: { Label("Move Down", systemImage: "arrow.down") }
                        .disabled(!canMoveDown)
                    Button(role: .destructive, action: onDelete) { Label("Delete Page", systemImage: "trash") }
                        .disabled(!canDelete)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .accessibilityLabel("Page \(pageNumber) options")
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("What happens on this page?")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .allowsHitTesting(false)
                TextField("Write it in English or \(language)", text: $draft.idea, axis: .vertical)
                    .lineLimit(2...5)
                    .focused(focusedField, equals: .pageIdea(draft.id))
                    .storyInputBackground()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Picture context (optional)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .allowsHitTesting(false)
                TextField("What the picture should show", text: $draft.pictureContext, axis: .vertical)
                    .lineLimit(1...4)
                    .focused(focusedField, equals: .pagePictureContext(draft.id))
                    .storyInputBackground()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.brown.opacity(0.3), lineWidth: 1)
        )
    }
}
