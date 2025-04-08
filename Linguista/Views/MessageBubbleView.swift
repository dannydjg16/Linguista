//
//  MessageBubbleView.swift
//  Linguista
//
//  Created by Daniel Grant on 1/15/25.
//

import Foundation
import SwiftUI

struct MessageBubbleView: View {
    
    @State var message: MessagingModel
    @ObservedObject var conversationViewModel: ConversationViewModel
    @State private var showModal = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            
            if message.isSentByUser {
                Spacer()
                if message.audioData != nil {
                    PlayAudioButton(message: message, conversationViewModel: conversationViewModel)
                }
                Text(message.message.content)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brown.opacity(0.15), lineWidth: 2))
                    .gesture(TapGesture()
                        .onEnded { _ in
                            showModal = true
                        }
                    )
                    .sheet(isPresented: $showModal) {
                        MessageModalView(message: $message, conversationViewModel: conversationViewModel)
                    }
                
            } else {
                Text(message.message.content)
                    .padding()
                    .background(Color.brown.opacity(0.2))
                    .cornerRadius(10)
                    .gesture(TapGesture()
                        .onEnded { _ in
                            showModal = true
                        }
                    )
                    .sheet(isPresented: $showModal) {
                        MessageModalView(message: $message, conversationViewModel: conversationViewModel)
                    }
                
                PlayAudioButton(message: message, conversationViewModel: conversationViewModel)
                Spacer()
            }
        }
        .padding([.leading, .trailing])
    }
}
