//
//  AudioPlayerView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/20/24.
//

import SwiftUI
import AVFoundation

class AudioPlayerManager: ObservableObject {
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0
    @Published var isPlaying = false
    
    private var player: AVAudioPlayer?
    private var timer: Timer?

    // Initialize with audio data
    init(audioData: Data) {
        setupPlayer(with: audioData)
    }
    
    private func setupPlayer(with audioData: Data) {
        do {
            player = try AVAudioPlayer(data: audioData)
            player?.prepareToPlay()
            duration = player?.duration ?? 0.0
            
            // Update currentTime periodically
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.currentTime = self?.player?.currentTime ?? 0.0
            }
        } catch {
            print("Error initializing player: \(error)")
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    func seek(to time: Double) {
        player?.currentTime = time
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - Audio Player View
struct AudioPlayerView: View {
    @ObservedObject var audioManager: AudioPlayerManager
    
    var body: some View {
        VStack {
            Slider(value: $audioManager.currentTime, in: 0...audioManager.duration, step: 0.1) { editing in
                if !editing {
                    audioManager.seek(to: audioManager.currentTime)
                }
            }
            .padding()
            
            HStack {
                Button(action: {
                    audioManager.togglePlayPause()
                }) {
                    Text(audioManager.isPlaying ? "Pause" : "Play")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
}
