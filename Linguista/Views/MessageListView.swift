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
            
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messagingViewModel.messages, id: \.id) { message in
                            MessageBubbleView(message: message, messagingViewModel: messagingViewModel)
                        }
                    }
                }
                .onChange(of: messagingViewModel.messages.count) {
                    
                    if let lastIndex = messagingViewModel.messages.last?.id {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                }
            }
    }
}
