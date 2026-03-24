//
//  MessageBubbleViewWithoutPlayAudioButton.swift
//  Linguista
//
//  Created by Daniel Grant on 3/11/25.
//

import Foundation
import SwiftUI

struct MessageBubbleViewWithoutPlayAudioButton: View {
    
    let message: String
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 10) {
                Text(message)
                    .padding()
                    .background(Color.brown.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.5), lineWidth: 4))
                    .cornerRadius(10)
            }
        }
    }
}
