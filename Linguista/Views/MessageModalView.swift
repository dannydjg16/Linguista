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
    @State var messageResponse: MessagingModel?
    
    
    var body: some View {
        
        Text(message.message.content)
            .border(Color.white, width: 1)
            .foregroundColor(Color.primary)
        
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
        
        if let response = messageResponse {
            TranslationBubbleView(message: response, conversationViewModel: conversationViewModel)
        }
    }
    
    func translateWithViewModel(message: MessagingModel) {
        let messages = [Message(role: "system", content: "Translate the word or sentence from Farsi to English or English to Farsi based on what is provided."), Message(role: "user", content: "\(message.message.content)")]
        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
        
        Task {
            messageResponse = await conversationViewModel.sendMessageGetMessage(completionRequest: dataModel)
        }
    }
}
