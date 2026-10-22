//
//  StoryPageDetailView.swift
//  Linguista
//
//  Created by Daniel Grant on 10/22/26.
//

import SwiftUI

struct StoryPageDetailView: View {
    let pageID: UUID
    @ObservedObject var viewModel: StoryViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    // Read from the view model so audio loaded here is saved back onto the story
    private var page: StoryPage? {
        viewModel.story?.pages.first(where: { $0.id == pageID })
    }

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(colorScheme == .light ? Color.white : Color.brown)
            }
            .frame(width: 44, height: 44)
            .background(colorScheme == .light ? Color.brown : Color.white)
            .clipShape(Circle())
            .padding([.top, .trailing])
        }

        Text("Inspect Page")
            .font(.title)
            .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)

        CommonDivider()

        if let page {
            ScrollView {
                VStack(spacing: 5) {
                    StoryImageView(imageState: page.imageState) {
                        viewModel.retryImage(for: page.id)
                    }
                    .padding()

                    InfoSection(title: "Message") {
                        MessageBubbleViewWithoutPlayAudioButton(message: page.text)
                    }

                    if let transliteration = page.transliteration {
                        InfoSection(title: "Transliteration") {
                            MessageBubbleViewWithoutPlayAudioButton(message: transliteration)
                        }
                    }

                    InfoSection(title: "Audio") {
                        if let audioData = page.audioData {
                            StoryAudioPlayer(audioData: audioData)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        } else if viewModel.loadingAudioPageID == page.id {
                            HStack {
                                ProgressView()
                                Text("Loading audio…")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Button(action: { Task { await viewModel.loadAudio(for: page.id) } }) {
                                Label("Load Audio", systemImage: "waveform")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.brown)
                            .padding(.horizontal)
                        }
                    }
                    .animation(.easeInOut, value: page.audioData != nil)

                    InfoSection(title: "Translation") {
                        MessageBubbleViewWithoutPlayAudioButton(message: page.translation)
                    }
                }
            }
        }
    }
}

// MARK: - Audio Player

// Owns the AudioPlayerManager so playback isn't reset each time the detail view re-renders
private struct StoryAudioPlayer: View {
    @StateObject private var audioManager: AudioPlayerManager

    init(audioData: Data) {
        _audioManager = StateObject(wrappedValue: AudioPlayerManager(audioData: audioData))
    }

    var body: some View {
        AudioPlayerView(audioManager: audioManager)
    }
}
