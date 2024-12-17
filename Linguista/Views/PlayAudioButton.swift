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
    
    var body: some View {
        if message.audioData != nil { // Check if the property is not nil
            Button(action: {
                messagingViewModel.playAudio(messagingModel: message)
            }) {
                Text("Play")
                    .bold()
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
