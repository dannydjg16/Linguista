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
    @State private var backgroundColor: Color = .yellow
    
    var body: some View {

        VStack {
            if let lastMessage = conversationViewModel.messages.last(where: { $0.isSentByUser == false } ) {
                MessageBubbleView(message: lastMessage, conversationViewModel: conversationViewModel)
            }
            
            Spacer()
            
            HStack {
                VStack {
                    Button(action: {
                        
                    }) {
                        Image(systemName: "microphone")
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 75, idealWidth: 75, maxWidth: 75, minHeight: 75, idealHeight: 75, maxHeight: 100)
                    .background(Color.brown)
                    .clipShape(Circle())
                }
            }
        }
    }
}
