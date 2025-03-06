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
    let conversationViewModel: ConversationViewModel
    @State private var showModal = false
    @State private var backgroundColor: Color = .white
    @State private var offset: CGSize = .zero // Tracks the bubble's position

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            
            if message.isSentByUser {
                Spacer()
                Text(message.message.content)
                    .padding()
                    .background(backgroundColor)
                    .cornerRadius(10)
                    .offset(offset) // Apply the offset to move the bubble
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brown.opacity(0.15), lineWidth: 2))
                    .gesture(TapGesture()
                        .onEnded { _ in
                            showModal = true
                        }
                    )
                    .sheet(isPresented: $showModal) {
                        MessageModalView(message: message)
                    }
                
            } else {
                Text(message.message.content)
                    .padding()
                    .background(Color.brown.opacity(0.2))
                    .cornerRadius(10)
                
                PlayAudioButton(message: message, conversationViewModel: conversationViewModel)
                Spacer()
            }
        }
    }
}
