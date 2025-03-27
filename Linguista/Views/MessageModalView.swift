//
//  MessageModalView.swift
//  Linguista
//
//  Created by Daniel Grant on 3/6/25.
//

import Foundation
import SwiftUI

struct MessageModalView: View {
    
    @Binding var message: MessagingModel
    @ObservedObject var conversationViewModel: ConversationViewModel
    @State var messageResponse: MessagingModel?
    @State var messageWithAudio: MessagingModel?
    @State var translatedMessage: MessagingModel?
    
    var body: some View {
        
        Spacer()
        
        HStack {
            Text(message.message.content)
                .border(Color.white, width: 1)
                .foregroundColor(Color.primary)
        }
        
        Spacer()
        
        HStack {
            Spacer()
            Button(action: {
                Task {
                    await translateWithVieswModel(messageToTranslate: message)
                }
            }) {
                Text("Translate")
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            Spacer()
        }
        
        Spacer()
            
        if let response = translatedMessage {
            Text(response.translatedMessageContent ?? "")
            HStack {
                Spacer()
                
                TranslationBubbleView(message: response, conversationViewModel: conversationViewModel)
                
                Spacer()
                
                Button(action: {
                    getAudioMessage(message: message)
                }) {
                    Text("Get Audio")
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                Spacer()
            }
        }
        
        if let audioMessage = messageWithAudio {
            
            Spacer()
            
            HStack {
                Spacer()
                
                PlayAudioButton(message: audioMessage, conversationViewModel: conversationViewModel)
                
                Spacer()
            }
            
            Spacer()
        }
        
        Spacer()
    }
    
    func translateWithVieswModel(messageToTranslate: MessagingModel) async {
        let messages = [Message(role: "system", content: "Translate the word or sentence from Farsi to English or English to Farsi based on what is provided."), Message(role: "user", content: "\(messageToTranslate.message.content)")]
        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
        
        Task {
            translatedMessage = await conversationViewModel.sendMessageGetMessageTest(completionRequest: dataModel)
            message.translatedMessageContent = messageResponse?.message.content
        }
    }
    
    func translateWithViewModel(messageToTranslate: MessagingModel) {
        Task {
            await conversationViewModel.getTranslationMessage(messagingModel: message)
        }
    }
    
    func getAudioMessage(message: MessagingModel) {
        Task {
            messageWithAudio = await conversationViewModel.fetchAndPlayAudio(messagingModel: message)
        }
    }
}
