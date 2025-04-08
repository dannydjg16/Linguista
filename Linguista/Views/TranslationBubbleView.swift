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
    @State private var color: Color = .blue
    
    var body: some View {
        if message.isSentByUser {
            VStack {
                HStack(alignment: .bottom, spacing: 10) {
                    Text(message.translatedMessageContent ?? "Loading...")
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.brown.opacity(0.15), lineWidth: 4))
                        .cornerRadius(10)
                }
            }
        } else {
            VStack {
                HStack(alignment: .bottom, spacing: 10) {
                    Text(message.translatedMessageContent ?? "Loading...")
                        .padding()
                        .background(.brown.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
    }
}

struct MessageBubbleViewWithoutPlayAudioButton: View {
    
    let message: MessagingModel
    @State private var color: Color = .blue
    
    var body: some View {
        if message.isSentByUser {
            VStack {
                HStack(alignment: .bottom, spacing: 10) {
                    Text(message.message.content)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.brown.opacity(0.15), lineWidth: 4))
                        .cornerRadius(10)
                }
            }
        } else {
            VStack {
                HStack(alignment: .bottom, spacing: 10) {
                    Text(message.message.content)
                        .padding()
                        .background(.brown.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
    }
}
