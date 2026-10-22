//
//  StoryPageView.swift
//  Linguista
//
//  Created by Daniel Grant on 4/6/26.
//

import SwiftUI

struct StoryPageView: View {
    let page: StoryPage
    @ObservedObject var viewModel: StoryViewModel
    @State private var showDetail = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                StoryImageView(imageState: page.imageState) {
                    viewModel.retryImage(for: page.id)
                }

                StoryCaptionView(
                    page: page,
                    showTranslation: viewModel.showTranslation,
                    isLoadingAudio: viewModel.loadingAudioPageID == page.id,
                    onPlayAudio: { Task { await viewModel.playAudio(for: page.id) } },
                    onInspect: { showDetail = true }
                )
            }
            .padding()
        }
        .sheet(isPresented: $showDetail) {
            StoryPageDetailView(pageID: page.id, viewModel: viewModel)
        }
    }
}

// MARK: - Story Image

struct StoryImageView: View {
    let imageState: StoryImageState
    let onRetry: () -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(uiColor: .secondarySystemBackground))
            // Matches the 1536x1024 images requested from the API
            .aspectRatio(3 / 2, contentMode: .fit)
            .overlay { content }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var content: some View {
        switch imageState {
        case .loaded(let data):
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            } else {
                failedView
            }
        case .failed:
            failedView
        case .notLoaded, .loading:
            VStack(spacing: 10) {
                ProgressView()
                Text("Illustrating this page…")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var failedView: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Couldn't illustrate this page.")
                .font(.caption)
                .foregroundColor(.secondary)
            Button("Try Again", action: onRetry)
                .buttonStyle(.bordered)
                .tint(.brown)
        }
    }
}

// MARK: - Story Caption

struct StoryCaptionView: View {
    let page: StoryPage
    let showTranslation: Bool
    let isLoadingAudio: Bool
    let onPlayAudio: () -> Void
    let onInspect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                // Like Wista's chat bubbles, lead with the transliteration and keep the original for the detail view
                Text(page.transliteration ?? page.text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: onPlayAudio) {
                    if isLoadingAudio {
                        ProgressView()
                    } else {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }
                .frame(width: 32, height: 32)
                .foregroundColor(.brown)
                .disabled(isLoadingAudio)
            }

            if showTranslation {
                Divider()
                Text(page.translation)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }

            Label("Tap to inspect", systemImage: "text.magnifyingglass")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture(perform: onInspect)
    }
}
