//
//  AudioFetcher.swift
//  Linguista
//
//  Created by Daniel Grant on 11/20/24.
//

import Foundation
import AVFoundation

class AudioFetcher: ObservableObject {
    @Published var audioPlayer: AVAudioPlayer?

    func fetchAudio() {
        guard let url = URL(string: "https://example.com/audio-endpoint") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching audio: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Invalid response or data")
                return
            }
            
            DispatchQueue.main.async {
                self.playAudio(data: data)
            }
        }
        task.resume()
    }
    
    private func playAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
        }
    }
}
