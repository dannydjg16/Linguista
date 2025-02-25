//
//  MessageBubbleView.swift
//  Linguista
//
//  Created by Daniel Grant on 1/15/25.
//

import Foundation
import SwiftUI

struct MessageBubbleView: View {
    let message: MessagingModel
    let messagingViewModel: ConversationViewModel

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.isSentByUser {
                Spacer()
                Text(message.message.content)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brown.opacity(0.15), lineWidth: 2))
                
            } else {
                Text(message.message.content)
                    .padding()
                    .background(Color.brown.opacity(0.2))
                    .cornerRadius(10)
                
                PlayAudioButton(message: message, messagingViewModel: messagingViewModel)
                Spacer()
            }
        }
    }
}
