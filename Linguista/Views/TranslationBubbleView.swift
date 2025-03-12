//
//  TranslationBubbleView.swift
//  Linguista
//
//  Created by Daniel Grant on 3/11/25.
//

import Foundation
import SwiftUI

struct TranslationBubbleView: View {
    
    let message: MessagingModel
    let conversationViewModel: ConversationViewModel

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {

                Text(message.message.content)
                    .padding()
                    .background(Color.brown.opacity(0.2))
                    .cornerRadius(10)
                
                PlayAudioButton(message: message, conversationViewModel: conversationViewModel)
        }
    }
}
