//
//  BackAndForthChatView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/10/25.
//

import Foundation
import SwiftUI

struct BackAndForthChatView: View {
    
    @ObservedObject var conversationViewModel: ConversationViewModel
    @State private var backgroundColor: Color = .yellow
    @Binding var innerSelection: Int
    
    var body: some View {
        
        if let lastMessage = conversationViewModel.messages.last(where: { $0.isSentByUser == false } ) {
            MessageBubbleView(message: lastMessage, conversationViewModel: conversationViewModel)
        }
        
        Spacer()
        
        HStack{
            Spacer()
            

            
            Spacer()
            
        }
        
        
        //            VStack{
        //                Button(action: {
        //                    // Action when the button is tapped
        //                    innerSelection += 1
        //                }) {
        //                    Image(systemName: "list.dash")
        //                        .foregroundColor(.white)
        //                }
        //                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
        //                .background(Color.brown)
        //                .clipShape(Circle())
        //
        //                Text("Restart Chat")
        //            }
        //
        //            Spacer()
        
        //            VStack{
        //                Button(action: {
        //                    // Action when the button is tapped
        //                    innerSelection += 1
        //                }) {
        //                    Image(systemName: "phone.fill")
        //                        .foregroundColor(.white)
        //                }
        //                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
        //                .background(Color.brown)
        //                .clipShape(Circle())
        //
        //                Text("New Conversation")
        //            }
        
        
        //     Spacer()
        
        VStack {
            
            ZStack {
                HStack {
                    Spacer()
                    
                    VStack{
                        Button(action: {
                            // Action when the button is tapped
                            innerSelection += 1
                        }) {
                            Image(systemName: "bubble.and.pencil")
                                .foregroundColor(.brown)
                        }
                        .frame(minWidth: 30, idealWidth: 30, maxWidth: 30, minHeight: 30, idealHeight: 30, maxHeight: 30)
                        .background(Color.white)
                        .clipShape(Circle())
                        
                    }
                }
                VStack{
                    Button(action: {
                        
                    }) {
                        Image(systemName: "microphone")
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 75, idealWidth: 75, maxWidth: 75, minHeight: 75, idealHeight: 75, maxHeight: 100)
                    .background(Color.brown)
                    .clipShape(Circle())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
