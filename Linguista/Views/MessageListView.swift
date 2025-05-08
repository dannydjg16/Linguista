//
//  MessageListView.swift
//  Linguista
//
//  Created by Daniel Grant on 1/15/25.
//

import Foundation
import SwiftUI

struct MessageListView: View {
    
    @ObservedObject var conversationViewModel: ConversationViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
            
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(conversationViewModel.messages, id: \.id) { message in
                            MessageBubbleView(message: message, conversationViewModel: conversationViewModel)
                        }
                    }
                    .padding(.top)
                }
                .onChange(of: conversationViewModel.messages.count) {
                    if let lastIndex = conversationViewModel.messages.last?.id {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                }
            }
            .background(colorScheme == .light ? Color.white : Color.black)
    }
}
