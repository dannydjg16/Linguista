//
//  MessageModalView.swift
//  Linguista
//
//  Created by Daniel Grant on 3/6/25.
//

import Foundation
import SwiftUI

struct MessageModalView: View {
    
    var message: MessagingModel
    @StateObject private var conversationViewModel = ConversationViewModel()
    @State private var translationResult = "See Translation"
    
    
    var body: some View {

        List{
            
            Section {
                Text(message.message.content)
                    .border(Color.white, width: 1)
                    .foregroundColor(Color.primary)
            }
            
            Section {
                HStack{
                    Spacer()
                    Button(action: {
                        translateWithViewModel(message: message)
                    }) {
                        Text("Translate")
                            .padding()
                            .background(Color.brown)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    Spacer()
                }
            }
            
            Section {
                if let response = message {
                        MessageBubbleView(message: response)
                    
                }
            }
        }
    
    func translateWithViewModel(message: MessagingModel) -> MessagingModel? {
        let messages = [Message(role: "system", content: "translate the word or sentence from Farsi to English or English to Farsi based on what is provided."), Message(role: "user", content: "\(message.message.content)")]
        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
        
        Task {
            return await conversationViewModel.sendMessageGetMessage(completionRequest: dataModel)
        }
        return nil
    }
}
