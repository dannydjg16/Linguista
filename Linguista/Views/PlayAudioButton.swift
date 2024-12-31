//
//  PlayAudioButton.swift
//  Linguista
//
//  Created by Daniel Grant on 12/11/24.
//

import Foundation
import SwiftUI

struct PlayAudioButton: View {
    let message: MessagingModel // Replace with your actual message type
    let messagingViewModel: ConversationViewModel // Replace with your view model type
    @State private var playbackSpeed: Float = 1.0 // Default speed
    @State private var isSpeedSelectorPresented: Bool = false // Tracks if the speed selector is shown
    
    var body: some View {
        if message.audioData != nil { // Check if the property is not nil
            Button(action: {
                // Call playAudio with the selected speed
                messagingViewModel.playAudio(messagingModel: message, speed: playbackSpeed)
            }) {
                Text("Play")
                    .bold()
                    .padding()
                    .frame(minWidth: 100) // Ensure a minimum width
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                isSpeedSelectorPresented = true
            }) {
                Text("Speed")
                    .font(.system(size: 14, weight: .regular)) // Smaller font size
                    .foregroundColor(.blue) // Link-like color
                    .underline() // Makes it look like a link
            }
            .sheet(isPresented: $isSpeedSelectorPresented) {
                SpeedSelectorView(playbackSpeed: $playbackSpeed)
            }
        }
    }
}
