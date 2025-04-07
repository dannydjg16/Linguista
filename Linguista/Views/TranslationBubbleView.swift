//
//  TranslationBubbleView.swift
//  Linguista
//
//  Created by Daniel Grant on 3/11/25.
//

import Foundation
import SwiftUI

struct TranslationBubbleViewWithoutPlayAudioButton: View {
    
    let message: MessagingModel
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 10) {
                Text(message.translatedMessageContent ?? "Loading...")
                    .padding()
                    .background(Color.brown.opacity(0.4))
                    .cornerRadius(10)
            }
        }
    }
}

struct MessageBubbleViewWithoutPlayAudioButton: View {
    
    let message: MessagingModel
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 10) {
                Text(message.message.content)
                    .padding()
                    .background(Color.brown.opacity(0.4))
                    .cornerRadius(10)
            }
        }
    }
}
