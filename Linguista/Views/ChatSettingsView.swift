//
//  ChatSettingsView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/25/25.
//


import Foundation
import SwiftUI

struct ChatSettingsView: View {

    @Binding var languageToTranslate: Int
    @Binding var innerSelection: Int
    @ObservedObject var conversationViewModel: ConversationViewModel
    @Environment(\.dismiss) var dismiss
    
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
                    innerSelection = 0
                    
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
                    innerSelection = 1
                    
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
