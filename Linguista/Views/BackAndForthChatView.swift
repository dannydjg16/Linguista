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
        
        if let lastMessage = messagingViewModel.messages.last {
            MessageBubbleView(message: lastMessage, messagingViewModel: messagingViewModel)
        }
        
        Spacer()
        
        HStack{
            Spacer()

            
            
            VStack{
                Button(action: {
                    // Action when the button is tapped
                    innerSelection += 1
                }) {
                    Image(systemName: "list.dash")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
                .background(Color.brown)
                .clipShape(Circle())
                
                Text("Chat Recap")
            }
            
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
            Spacer()
            Text("Get reply in:")
            HStack{
                
                Spacer()
                
                VStack{
                    Button(action: {
                        // Action when the button is tapped
                        innerSelection += 1
                    }) {
                        Image(systemName: "waveform")
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 75, idealWidth: 75, maxWidth: 75, minHeight: 75, idealHeight: 75, maxHeight: 100)
                    .background(Color.brown)
                    .clipShape(Circle())
                    
                    Text("English")
                }
                
                Spacer()
                
                VStack {
                    Button(action: {
                        // Action when the button is tapped
                        innerSelection += 1
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
                    .background(Color.brown)
                    .clipShape(Circle())
                    
                    Text("Replay Message")
                }
                
                Spacer()
                
                VStack{
                    Button(action: {
                        // Action when the button is tapped
                        innerSelection += 1
                    }) {
                        Image(systemName: "waveform")
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 75, idealWidth: 75, maxWidth: 75, minHeight: 75, idealHeight: 75, maxHeight: 100)
                    .background(Color.brown)
                    .clipShape(Circle())
                    
                    Text("Farsi")
                }
                
                Spacer()
                
            }
            Spacer()
        }
        .background(Color.brown.opacity(0.1))
        .cornerRadius(10)
    }
}
