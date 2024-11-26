//
//  TtsViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 11/25/24.
//

import Foundation
import AVFoundation

class TtsViewModel: ObservableObject {
    
    @Published var data: Data?
    private let completionsService = CompletionsService.shared
    @Published var audioPlayer: AVAudioPlayer?
    
    func fetchTts(ttsRequest: TtsRequest) async throws -> Data {
        let response = try await completionsService.fetchTts(ttsRequest: ttsRequest)
        // Add response to message array
        return response
    }
    
    func playAudio(with data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}
