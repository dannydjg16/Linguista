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
    @StateObject private var conversationViewModel = ConversationViewModel()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    let persistenceController = PersistenceController.shared
    
    init() {
        setupAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(conversationViewModel)
                .environmentObject(speechRecognizer)
                .environmentObject(AccountManager(context: persistenceController.container.viewContext))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    
//    var body: some Scene {
//        WindowGroup {
//            ProfileView()
//        }
//    }
    
    
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
