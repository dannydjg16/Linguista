//
//  BackAndForthChatView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/10/25.
//

import Foundation
import SwiftUI

struct BackAndForthChatView: View {
    
    @ObservedObject var conversationViewModel: ConversationViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if let lastMessage = conversationViewModel.messages.last(where: { $0.isSentByUser == false } ) {
                MessageBubbleView(message: lastMessage, conversationViewModel: conversationViewModel)
                    .padding(.top)
            }
            
            Spacer()
            
            Divider()
                .frame(height: 1)
                .background(Color.black.opacity(0.3))
                .padding(.leading)
                .padding(.trailing)
            
            VStack {
                HStack {
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await conversationViewModel.sendMessageForUsera()
                        }
                    }) {
                        Image(systemName: "arrow.up.message")
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 75, idealWidth: 75, maxWidth: 75, minHeight: 75, idealHeight: 75, maxHeight: 100)
                    .background(Color.brown)
                    .clipShape(Circle())
                    
                    Spacer()
                    
                    Button(action: {
                        //textToSpeech()
                    }) {
                        Image(systemName: "microphone")
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 75, idealWidth: 75, maxWidth: 75, minHeight: 75, idealHeight: 75, maxHeight: 100)
                    .background(Color.brown)
                    .clipShape(Circle())
                    
                    Spacer()
                }
            }
        }
        .background(colorScheme == .light ? Color.white : Color.black)
    }
}
