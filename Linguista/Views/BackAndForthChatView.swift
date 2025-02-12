//
//  BackAndForthChatView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/10/25.
//

import Foundation
import SwiftUI

struct BackAndForthChatView: View {
    
    @ObservedObject var messagingViewModel: ConversationViewModel
    @State private var backgroundColor: Color = .yellow
    @Binding var innerSelection: Int
    
    var body: some View {
        
        Text("Last Message: ")
        
        if let lastMessage = messagingViewModel.messages.last {
            
            //backgroundColor = (backgroundColor == .yellow) ? .purple : .yellow
            
            MessageBubbleView(message: lastMessage, messagingViewModel: messagingViewModel)
        }
        
        Button("View Messages") {
            innerSelection += 1
        }
    }
}
