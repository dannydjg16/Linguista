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
    @EnvironmentObject var conversationViewModel: ConversationViewModel
//    @State var messageWithAudio: MessagingModel?
    //@State var translatedMessage: MessagingModel?
    //@State var transliteratedMessage: MessagingModel?
    //@State var translatedMessageWithAudio: MessagingModel?
    @State private var showWarning = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var accountManager: AccountManager
    
    var body: some View {
        HStack() {
            Spacer()
            VStack{
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(colorScheme == .light ? Color.white : Color.brown)
                }
                .frame(minWidth: 40, idealWidth: 50, maxWidth: 50, minHeight: 40, idealHeight: 50, maxHeight: 50)
                .background(colorScheme == .light ? Color.brown : Color.white)
                .clipShape(Circle())
                .padding([.top, .trailing])
            }
        }
        
        Text("Inspect Message")
            .font(.title)
            .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
        
        ScrollView {
            VStack(spacing: 5){
                
                Divider()
                    .frame(height: 1)
                    .background(colorScheme == .light ? Color.black.opacity(0.3) : Color.white)
                    .padding([.leading, .trailing])
                
                HStack {
                    Text("Message:")
                        .padding(.leading)
                        .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    MessageBubbleViewWithoutPlayAudioButton(message: message.message.content)
                }
                
                Spacer()
                Divider()
                    .frame(height: 1)
                    .background(colorScheme == .light ? Color.black.opacity(0.3) : Color.white)
                    .padding([.leading, .trailing])
                
                
                HStack {
                    Text("Audio:")
                        .padding(.leading)
                        .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
                    Spacer()
                }
                
                Spacer()
                
                if message.audioData != nil {
                    
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
                        getAudioMessage(messageToGetAudioFor: message)
                    }) {
                        Text("Get Audio")
                            .padding()
                            .background(Color.brown)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
                
                Spacer()
                Divider()
                    .frame(height: 1)
                    .background(colorScheme == .light ? Color.black.opacity(0.3) : Color.white)
                    .padding([.leading, .trailing])
                
                
                
                HStack {
                    Text("Translation:")
                        .padding(.leading)
                        .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
                    Spacer()
                }
                
                Spacer()
                
                if message.translatedMessageContent != nil {
                    
                    HStack {
                        Spacer()
                        
                        MessageBubbleViewWithoutPlayAudioButton(message: message.translatedMessageContent!)
                        
                        Spacer()
                    }
                } else {
                    Button(action: {
                        Task {
                            await translateWithViewModel(messageToTranslate: message)
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
                    .background(colorScheme == .light ? Color.black.opacity(0.3) : Color.white)
                    .padding([.leading, .trailing])
                
                
                
                HStack {
                    Text("Translation Audio:")
                        .padding(.leading)
                        .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
                    Spacer()
                }
                
                Spacer()
                
                if message.translatedAudioData != nil {
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        AudioPlayerView(audioManager: AudioPlayerManager(audioData: message.translatedAudioData!))
                            .transition(.slide)
                        
                        Spacer()
                    }
                    
                    Spacer()
                } else {
                    Button(action: {
                        if message.translatedMessageContent != nil {
                            getAudioMessageForTranslatedMessage(messageToGetAudioFor: message)
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
                    .background(colorScheme == .light ? Color.black.opacity(0.3) : Color.white)
                    .padding([.leading, .trailing])
                Spacer()
            }
            .animation(.easeInOut, value: showWarning)
        }
    }
    
    func translateWithViewModel(messageToTranslate: MessagingModel) async {
        let messages = [Message(role: "system", content: "Translate the word or sentence from \(Utilities.getLanguageName(by: accountManager.languageToLearn)) to English if \(Utilities.getLanguageName(by: accountManager.languageToLearn)) is provided. The translation should be very informal like chatting with an infant. Otherwise, translate from English to \(Utilities.getLanguageName(by: accountManager.languageToLearn)) if English is provided."), Message(role: "user", content: "\(messageToTranslate.message.content)")]
        let dataModel = CompletionsRequest(model: selectedCompletionsModel, messages: messages, maxTokens: maxCompletionTokens, topP: 1)
        
        Task {
//            let tm = await conversationViewModel.sendMessageGetMessage(completionRequest: dataModel)
//            message.translatedMessageContent = tm?.message.content
//            _ = conversationViewModel.setTranslatedMessageAndAudio(messagingModel: tm!)
            
            message.translatedMessageContent = await conversationViewModel.sendMessageGetMessageString(completionRequest: dataModel)
        }
    }
    
    func getAudioMessage(messageToGetAudioFor: MessagingModel) {
        Task {
            //messageWithAudio = await conversationViewModel.fetchAndPlayAudioForMessagingModel(messagingModel: messageToGetAudioFor)
            //message.audioData = await conversationViewModel.fetchAndPlayAudioReturnData(messagingModel: messageToGetAudioFor)
            //_ = conversationViewModel.setTranslatedMessageAndAudio(messagingModel: message)
            
            message.audioData = await conversationViewModel.fetchAndPlayAudioReturnData(messageToConvertAndPlay: messageToGetAudioFor.translatedMessageContent!)
        }
    }
    
    func getAudioMessageForTranslatedMessage(messageToGetAudioFor: MessagingModel) {
        Task {
//            translatedMessageWithAudio = await conversationViewModel.fetchAndPlayAudioForTranslatedMessage(messagingModel: messageToGetAudioFor)
//            message.translatedAudioData = translatedMessageWithAudio?.translatedAudioData
//            _ = conversationViewModel.setTranslatedMessageAndAudio(messagingModel: message)
            
            message.translatedAudioData = await conversationViewModel.fetchAndPlayAudioReturnData(messageToConvertAndPlay: messageToGetAudioFor
                .translatedMessageContent!)
            
        }
    }
}

struct MessageModalView_Previews: PreviewProvider {
    
    @State static var message: MessagingModel = MessagingModel(message: Message(role: "aaa", content: "bbb"), isSentByUser: true)
    
    static var previews: some View {
        MessageModalView(message: $message)
    }
}
