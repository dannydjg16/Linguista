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
    @Published var audioPlayer: AVAudioPlayer?
    private let completionsService = CompletionsService.shared
    
    func fetchTts(ttsRequest: TtsRequest) async throws -> Data {
        let response = try await completionsService.fetchTts(ttsRequest: ttsRequest)
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
    
    func playAudio(with data: Data, speed: Float) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.rate = speed
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}
