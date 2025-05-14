//
//  LinguistaApp.swift
//  Linguista
//
//  Created by Daniel Grant on 6/7/24.
//

import SwiftUI
import AVFoundation

@main
struct LinguistaApp: App {
    
    init() {
        setupAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
}
