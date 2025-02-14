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
                
                //backgroundColor = (backgroundColor == .yellow) ? .purple : .yellow
                
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
            
            VStack{
                Button(action: {
                    // Action when the button is tapped
                    innerSelection += 1
                }) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
                .background(Color.brown)
                .clipShape(Circle())
                
                Text("Chat Recap")
            }
            
            Spacer()
            
            VStack{
                Button(action: {
                    // Action when the button is tapped
                    innerSelection += 1
                }) {
                    Image(systemName: "questionmark")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
                .background(Color.brown)
                .clipShape(Circle())
                
                Text("Some action")
            }
            
            Spacer()
        }
        
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
            
            VStack{
                Button(action: {
                    // Action when the button is tapped
                    innerSelection += 1
                }) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
                .background(Color.brown)
                .clipShape(Circle())
                
                Text("End ")
            }
            
            Spacer()
            
            VStack{
                Button(action: {
                    // Action when the button is tapped
                    innerSelection += 1
                }) {
                    Image(systemName: "questionmark")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
                .background(Color.brown)
                .clipShape(Circle())
                
                Text("Some action")
            }
            
            Spacer()
        }
        
        Spacer()
        
        HStack{
            //Spacer()
            
            VStack{
                Button(action: {
                    // Action when the button is tapped
                    innerSelection += 1
                }) {
                    Image(systemName: "microphone")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 50, idealWidth: 100, maxWidth: 150, minHeight: 50, idealHeight: 100, maxHeight: 150)
                .background(Color.brown)
                .clipShape(Circle())
                
                Text("Talk")
            }
            
            //Spacer()
        }
        
        Spacer()
    }
}
