//
//  TalkingChatView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/10/25.
//

import Foundation
import SwiftUI

struct TalkingChatView: View {
    
    @EnvironmentObject var conversationViewModel: ConversationViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            
            MessageListView()
                .background(Color.white)
                .cornerRadius(10)
            
            Spacer()
            
            CommonDivider()
            
            VStack {
                HStack {
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await conversationViewModel.sendMessageForUser()
                        }
                    }) {
                        Image(systemName: "arrow.up.message")
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 75, idealWidth: 75, maxWidth: 75, minHeight: 75, idealHeight: 75, maxHeight: 100)
                    .background(Color.brown)
                    .clipShape(Circle())
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "microphone")
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 75, idealWidth: 75, maxWidth: 75, minHeight: 75, idealHeight: 75, maxHeight: 100)
                    .background(Color.brown)
                    .clipShape(Circle())
                    
                    Spacer()
                }
            }
        }
        .background(colorScheme == .light ? Color.white : Color.black)
    }
}
