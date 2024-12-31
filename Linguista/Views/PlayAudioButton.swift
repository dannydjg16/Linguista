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
        HStack(alignment: .bottom, spacing: 10) {
            if message.audioData != nil { // Check if the property is not nil
                Button(action: {
                    // Call playAudio with the selected speed
                    messagingViewModel.playAudio(messagingModel: message, speed: playbackSpeed)
                }) {
//                    Image("arrow.clockwise")
//                        .padding()
//                        .frame(minWidth: 20) // Ensure a minimum width
//                        .font(.system(size: 14, weight: .regular))
//                        .background(Color.brown)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
                    Image(systemName: "arrow.clockwise") // Replace with a symbol of your choice
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20) // Adjust size as needed
                                    .padding()
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
                }
                .sheet(isPresented: $isSpeedSelectorPresented) {
                    SpeedSelectorView(playbackSpeed: $playbackSpeed)
                }
            }
        }
    }
}
