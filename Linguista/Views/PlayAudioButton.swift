//
//  PlayAudioButton.swift
//  Linguista
//
//  Created by Daniel Grant on 12/11/24.
//

import Foundation
import SwiftUI

struct PlayAudioButton: View {
    let message: MessagingModel
    let conversationViewModel: ConversationViewModel 
    @State private var playbackSpeed: Float = 1.0
    @State private var isSpeedSelectorPresented: Bool = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.audioData != nil {
                Button(action: {
                    // Call playAudio with the selected speed
                    conversationViewModel.playAudio(messagingModel: message, speed: playbackSpeed)
                }) {
                    Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
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
                        .presentationDetents([.fraction(0.3)])
                }
            }
        }
    }
}
