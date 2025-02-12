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
        
        VStack{
            Button(action: {
                // Action when the button is tapped
                innerSelection += 1
            }) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.white)
            }
            .frame(minWidth: 25, idealWidth: 50, maxWidth: 75, minHeight: 25, idealHeight: 50, maxHeight: 75)
            .background(Color.brown)
            .clipShape(Circle())
            
            Text("Chat Recap")
        }
    }
}
