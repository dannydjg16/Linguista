//
//  ChatOptionsView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/25/25.
//


import Foundation
import SwiftUI

struct ChatOptionsView: View {

    @Binding var chatTabViewSelectedValue: Int
    @EnvironmentObject var conversationViewModel: ConversationViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        HStack() {
            Spacer()
            VStack{
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.brown)
                }
                .frame(minWidth: 40, idealWidth: 50, maxWidth: 50, minHeight: 40, idealHeight: 50, maxHeight: 50)
                .background(Color.white )
                .clipShape(Circle())
            }
        }
        
        Text("Chat Options")
            .font(.title)
            .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
        Divider()
            .frame(height: 1)
            .background(colorScheme == .light ? Color.black.opacity(0.3) : Color.white)
            .padding(.leading)
            .padding(.trailing)

        Spacer()

        HStack() {
            
            Spacer()
            
            VStack{
                Button(action: {
                    conversationViewModel.resetChatWithSamePrompt()
                    dismiss()
                }) {
                    Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
                .background(Color.brown)
                .clipShape(Circle())

                Text("Restart Chat")
            }
            
            Spacer()
            
            VStack{
                Button(action: {
                    conversationViewModel.makeNewChatWithNewPrompt()
                    dismiss()
                }) {
                    Image(systemName: "text.insert")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
                .background(Color.brown)
                .clipShape(Circle())

                Text("New Chat")
            }
            
            Spacer()
        }
        
        Spacer()
        
        HStack() {
            
            Spacer()
            
            VStack{
                Button(action: {
                    dismiss()
                    chatTabViewSelectedValue = 0
                }) {
                    Image(systemName: "microphone")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
                .background(Color.brown)
                .clipShape(Circle())
                
                Text("Continue Chat")
            }
            
            Spacer()
            
            VStack{
                Button(action: {
                    dismiss()
                    chatTabViewSelectedValue = 1
                    
                }) {
                    Image(systemName: "bubble.and.pencil")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 25, idealWidth: 50, maxWidth: 50, minHeight: 25, idealHeight: 50, maxHeight: 50)
                .background(Color.brown)
                .clipShape(Circle())
                
                Text("Chat Recap")
            }
            
            Spacer()
        }
        Spacer()
    }
}
