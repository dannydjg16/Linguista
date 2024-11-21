//
//  AudioPlayerView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/20/24.
//

import Foundation
import SwiftUI

struct AudioPlayerView: View {
    @StateObject private var audioFetcher = AudioFetcher()
    
    var body: some View {
        VStack {
            Text("Audio Player")
                .font(.headline)
            
            HStack {
                Button("Pause") { audioFetcher.audioPlayer?.pause() }
                Button("Resume") { audioFetcher.audioPlayer?.play() }
                Button("Stop") { audioFetcher.audioPlayer?.stop() }
            } 
        }
        .padding()
    }
}
