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
    @State private var showWarning = false
    
    var body: some View {
        VStack{
            
            Text("Inspect Message")
                .font(.title)
                .padding(.top)
                .foregroundColor(Color(red: 0.3, green: 0.15, blue: 0.05)) 

            Divider()
                .frame(height: 1)
                .background(Color.black.opacity(0.3))
                .padding(.leading)
                .padding(.trailing)
            
            HStack {
                Text("Message:")
                    .padding(.leading)
                    .foregroundColor(Color(red: 0.3, green: 0.15, blue: 0.05))
                Spacer()
            }
            
            Spacer()
            
            HStack {
                MessageBubbleViewWithoutPlayAudioButton(message: message)
            }
            
            Spacer()
            Divider()
                .frame(height: 1)
                .background(Color.black.opacity(0.3))
                .padding(.leading)
                .padding(.trailing)
            
            HStack {
                Text("Translation:")
                    .padding(.leading)
                    .foregroundColor(Color(red: 0.3, green: 0.15, blue: 0.05))
                Spacer()
            }
           
            Spacer()
                        
            if let response = translatedMessage {
                
                HStack {
                    
                    Spacer()
                    
                    TranslationBubbleViewWithoutPlayAudioButton(message: response)
                    
                    Spacer()
                }
            } else if message.translatedMessageContent != nil {
                
                HStack {
                    Spacer()
                    
                    TranslationBubbleViewWithoutPlayAudioButton(message: message)
                    
                    Spacer()
                }
            } else {
                Button(action: {
                    Task {
                        await translateWithVieswModel(messageToTranslate: message)
                    }
                }) {
                    Text("Get Translation")
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            
            Spacer()
            Divider()
                .frame(height: 1)
                .background(Color.black.opacity(0.3))
                .padding(.leading)
                .padding(.trailing)
            
            HStack {
                Text("Audio:")
                    .padding(.leading)
                    .foregroundColor(Color(red: 0.3, green: 0.15, blue: 0.05))
                Spacer()
            }
            
            Spacer()
            
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
            } else {
                Button(action: {
                    if message.translatedMessageContent != nil {
                        getAudioMessage(messageToGetAudioFor: message)
                    } else {
                        showWarning = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showWarning = false
                        }
                    }
                }) {
                    Text("Get Audio")
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                if showWarning {
                    Text("Need to Translate Message First!")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 5)
                        .transition(.opacity)
                }
            }
            
            Spacer()
            Divider()
                .frame(height: 1)
                .background(Color.black.opacity(0.3))
                .padding(.leading)
                .padding(.trailing)
            Spacer()
        }
        .animation(.easeInOut, value: showWarning)
    }
    
    func translateWithVieswModel(messageToTranslate: MessagingModel) async {
        let messages = [Message(role: "system", content: "Translate the word or sentence from Farsi to English or English to Farsi based on what is provided."), Message(role: "user", content: "\(messageToTranslate.message.content)")]
        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
        
        Task {
            translatedMessage = await conversationViewModel.sendMessageGetMessageTest(completionRequest: dataModel)
            message.translatedMessageContent = translatedMessage?.translatedMessageContent
            _ = conversationViewModel.setTranslatedMessage(messagingModel: message)
        }
    }
    
    func translateWithViewModel(messageToTranslate: MessagingModel) async {
        let messages = [Message(role: "system", content: "Translate the word or sentence from Farsi to English if Farsi is provided. Otherwise, translate from English to Farsi if English is provided."), Message(role: "user", content: "\(messageToTranslate.message.content)")]
        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
        
        Task {
            translatedMessage = await conversationViewModel.sendMessageGetMessage(completionRequest: dataModel)
            message.translatedMessageContent = translatedMessage?.translatedMessageContent
            _ = conversationViewModel.setTranslatedMessage(messagingModel: message)
        }
    }
    
    func getAudioMessage(messageToGetAudioFor: MessagingModel) {
        Task {
            messageWithAudio = await conversationViewModel.fetchAndPlayAudioForMessagingModal(messagingModel: messageToGetAudioFor)
            message.audioData = messageWithAudio?.audioData
            _ = conversationViewModel.setTranslatedMessage(messagingModel: message)
        }
    }
}

struct MessageModalView_Previews: PreviewProvider {
    //@State static var message: MessagingModel = MessagingModel(message: Message(role: "aaa", content: "bbb"), isSentByUser: true, translatedMessageContent: "translation")
    
    @State static var message: MessagingModel = MessagingModel(message: Message(role: "aaa", content: "bbb"), isSentByUser: true)
    
    static var previews: some View {
        MessageModalView(message: $message, conversationViewModel: ConversationViewModel())
    }
}
