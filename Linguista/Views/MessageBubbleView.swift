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
                    .simultaneousGesture( // Use simultaneousGesture instead of .gesture
                        DragGesture(minimumDistance: 20, coordinateSpace: .local)
                            .onChanged { value in
                                offset = CGSize(width: value.translation.width, height: 0)
                                if value.translation.width > 0 {
                                    backgroundColor = .red.opacity(Double(value.translation.width) / 100)
                                }
                            }
                            .onEnded { value in
                                if value.translation.width > 50 {
                                    backgroundColor = .red
                                    offset = CGSize(width: 50, height: 0)
                                } else {
                                    backgroundColor = .gray
                                    offset = .zero
                                }
                            }
                    )
                    .sheet(isPresented: $showModal) {
                        AccountView()
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
