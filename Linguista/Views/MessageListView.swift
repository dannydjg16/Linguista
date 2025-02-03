//
//  MessageListView.swift
//  Linguista
//
//  Created by Daniel Grant on 1/15/25.
//

import Foundation
import SwiftUI

struct MessageListView: View {
    @ObservedObject var messagingViewModel: ConversationViewModel

    var body: some View {
        if let firstMessage = messagingViewModel.messages.first {
            Text("Topic: \(firstMessage.message.content)")
        }
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messagingViewModel.messages, id: \.id) { message in
                        MessageBubbleView(message: message, messagingViewModel: messagingViewModel)
                    }
                }
            }
            .onChange(of: messagingViewModel.messages.count) {
                // Here, I want to maybe change the color or picture on the screen. So when you should be talking and when the thing is tlaking.
                // Might be a better way to do it but for now I have this array being checked anyways 
                
                
                
                
                
                if let lastIndex = messagingViewModel.messages.last?.id {
                    withAnimation {
                        scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                    }
                }
            }
        }
    }
}
