//
//  MessageModalView.swift
//  Linguista
//
//  Created by Daniel Grant on 3/6/25.
//

import Foundation
import SwiftUI

struct MessageModalView: View {
    
    var message: MessagingModel
    @StateObject private var conversationViewModel = ConversationViewModel()

    var body: some View {
        VStack{
            if message.isSentByUser {
                Text(message.message.content)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brown.opacity(0.15), lineWidth: 2))
            }
            else {
                Text(message.message.content)
                    .padding()
                    .background(Color.brown.opacity(0.2))
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding(.top)

    }
}
