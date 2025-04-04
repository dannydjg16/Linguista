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
    @State var messageWithAudio: MessagingModel?
    @State var translatedMessage: MessagingModel?
    
    var body: some View {
        
        Spacer()
        
        HStack {
            MessageBubbleViewWithoutPlayAudioButton(message: message)
        }
        
        Spacer()
        
        HStack {
            Spacer()
            
            if translatedMessage == nil && message.translatedMessageContent == nil {
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
            }
            
            Spacer()
        }
        
        Spacer()
        
        if let response = translatedMessage {
            
            HStack {
                Spacer()
                
                TranslationBubbleViewWithoutPlayAudioButton(message: response)
                
                Spacer()
            }
            HStack {
                if messageWithAudio == nil && message.audioData == nil {
                    Button(action: {
                        getAudioMessage(messageToGetAudioFor: message)
                    }) {
                        Text("Get Audio")
                            .padding()
                            .background(Color.brown)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
            }
            
        } else if message.translatedMessageContent != nil {
            HStack {
                Spacer()
                
                TranslationBubbleViewWithoutPlayAudioButton(message: message)
                
                Spacer()
            }
            
            HStack {
                if messageWithAudio == nil && message.audioData == nil {
                    Button(action: {
                        getAudioMessage(messageToGetAudioFor: message)
                    }) {
                        Text("Get Audio")
                            .padding()
                            .background(Color.brown)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
            }
        }
        
        if let audioMessage = messageWithAudio {
            
            Spacer()
            
            HStack {
                Spacer()
                
                AudioPlayerView(audioManager: AudioPlayerManager(audioData: audioMessage.audioData!))
                
                Spacer()
            }
            
            Spacer()
        } else if message.audioData != nil {
            
            Spacer()
            
            HStack {
                Spacer()
                
                AudioPlayerView(audioManager: AudioPlayerManager(audioData: message.audioData!))
                    .transition(.slide)
                
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
            message.translatedMessageContent = translatedMessage?.translatedMessageContent
            var success = conversationViewModel.setTranslatedMessage(messagingModel: message)
        }
    }
    
    func translateWithViewModel(messageToTranslate: MessagingModel) async {
        let messages = [Message(role: "system", content: "Translate the word or sentence from Farsi to English or English to Farsi based on what is provided."), Message(role: "user", content: "\(messageToTranslate.message.content)")]
        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
        
        Task {
            translatedMessage = await conversationViewModel.sendMessageGetMessage(completionRequest: dataModel)
            message.translatedMessageContent = translatedMessage?.translatedMessageContent
            var success = conversationViewModel.setTranslatedMessage(messagingModel: message)
        }
    }
    
    func getAudioMessage(messageToGetAudioFor: MessagingModel) {
        Task {
            messageWithAudio = await conversationViewModel.fetchAndPlayAudioForMessagingModal(messagingModel: messageToGetAudioFor)
            message.audioData = messageWithAudio?.audioData
            var success = conversationViewModel.setTranslatedMessage(messagingModel: message)
        }
    }
}

//struct MessageModalView_Previews: PreviewProvider {
//    @State static var message: MessagingModel = MessagingModel(message: Message(role: "aaa", content: "bbb"), isSentByUser: true, translatedMessageContent: "translation")
//    
//    static var previews: some View {
//        MessageModalView(message: $message, conversationViewModel: ConversationViewModel())
//    }
//}
