//
//  AudioPlayerView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/20/24.
//

import SwiftUI
import AVFoundation
import SwiftUI
import AVFoundation

// MARK: - Audio Player Manager
class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0
    @Published var isPlaying = false
    @Published var playbackRate: Float = 1.0
    
    private var player: AVAudioPlayer?
    private var timer: Timer?

    init(audioData: Data) {
        super.init() // Required when inheriting from NSObject
        setupPlayer(with: audioData)
    }
    
    private func setupPlayer(with audioData: Data) {
        do {
            player = try AVAudioPlayer(data: audioData)
            player?.enableRate = true
            player?.delegate = self
            player?.prepareToPlay()
            duration = player?.duration ?? 0.0
            
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
            player?.rate = playbackRate
        }
        isPlaying.toggle()
    }
    
    func seek(to time: Double) {
        player?.currentTime = time
    }
    
    func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
        player?.rate = rate
    }
    
    // Delegate method to handle audio completion
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false // Reset to "Play" state
            currentTime = 0.0 // Optional: Reset slider to start
            player.currentTime = 0.0 // Optional: Reset player to start
        }
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
            
            VStack {
                Text("Playback Speed: \(audioManager.playbackRate, specifier: "%.1f")x")
                    .font(.caption)
                Slider(value: $audioManager.playbackRate, in: 0.5...2.0, step: 0.1) { editing in
                    if !editing {
                        audioManager.setPlaybackRate(audioManager.playbackRate)
                    }
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
