//
//  AudioPlayerView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/20/24.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @StateObject private var ttsViewModel = TtsViewModel()
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Fetching Audio...")
            } else {
                Button("Fetch & Play Audio") {
                    Task {
                        await fetchAndPlayAudio()
                    }
                }
            }

            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }

    private func fetchAndPlayAudio() async {
        isLoading = true
        errorMessage = nil

        do {
            let ttsRequest = TtsRequest(model: "tts-1", input: "Danny is Cool", voice: "shimmer", speed: 0.9)
            let audioData = try await ttsViewModel.fetchTts(ttsRequest: ttsRequest)
            ttsViewModel.playAudio(with: audioData)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
