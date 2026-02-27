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
    @EnvironmentObject var conversationViewModel: ConversationViewModel
    @State private var showModal = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            
            if message.isSentByUser {
                HStack(alignment: .center, spacing: 0) {
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
                            MessageModalView(message: $message)
                        }
                    
                    Rectangle()
                        .frame(width: 12, height: 3)
                        .foregroundColor(Color.brown.opacity(0.6))
                        .cornerRadius(2)
                        .padding(.trailing, -8)
                }

                
            } else {
                VStack(alignment: .leading) {
                    Text("Wista")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                    
                    HStack(alignment: .center, spacing: 0) {
                        Rectangle()
                            .frame(width: 12, height: 3)
                            .foregroundColor(Color.brown.opacity(0.6))
                            .cornerRadius(2)
                            .padding(.leading, -8)
                        
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
                                MessageModalView(message: $message)
                            }
                        
                        PlayAudioButton(message: message, conversationViewModel: conversationViewModel)
                        Spacer()
                    }
                }
            }
        }
        .padding([.leading, .trailing])
    }
}
