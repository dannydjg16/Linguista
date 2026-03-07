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
                
                CommonDivider()
                
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
                
                CommonDivider()
            
                
                if message.transliteratedMessageContent != nil {
                    
                    HStack {
                        Text("Transliteration:")
                            .padding(.leading)
                            .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        MessageBubbleViewWithoutPlayAudioButton(message: message.transliteratedMessageContent!)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    CommonDivider()
                }

                CommonDivider()
                
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
                
                CommonDivider()
                
                VStack {
                    
                    CommonDivider()
                    
                    HStack {
                        Text("Translation:")
                            .padding([.leading])
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
                    
                    CommonDivider()
                }
                .background(Color.brown.opacity(0.1))
                .cornerRadius(8)

                
                if message.translatedTransliteratedMessageContent != nil {
                    
                    HStack {
                        Text("Translated Transliteration:")
                            .padding(.leading)
                            .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        MessageBubbleViewWithoutPlayAudioButton(message: message.translatedTransliteratedMessageContent!)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    CommonDivider()
                }
                
                
                
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
                
                CommonDivider()
                
                Spacer()
            }
            .animation(.easeInOut, value: showWarning)
        }
    }
    
    func translateWithViewModel(messageToTranslate: MessagingModel) async {
        let messages = [Message(role: "system", content: "Translate the word or sentence from \(Utilities.getLanguageName(by: accountManager.languageToLearn)) to English if \(Utilities.getLanguageName(by: accountManager.languageToLearn)) is provided. The translation should be very informal like chatting with an infant. Otherwise, translate from English to \(Utilities.getLanguageName(by: accountManager.languageToLearn)) if English is provided."), Message(role: "user", content: "\(messageToTranslate.message.content)")]
        let dataModel = CompletionsRequest(model: selectedCompletionsModel, messages: messages, maxTokens: maxCompletionTokens, topP: 1)
        
        Task {
            message.translatedMessageContent = await conversationViewModel.sendMessageGetMessageString(completionRequest: dataModel)
        }
    }
    
    func getAudioMessage(messageToGetAudioFor: MessagingModel) {
        Task {
            message.audioData = await conversationViewModel.fetchAndPlayAudioReturnData(messageToConvertAndPlay: messageToGetAudioFor.translatedMessageContent!)
        }
    }
    
    func getAudioMessageForTranslatedMessage(messageToGetAudioFor: MessagingModel) {
        Task {
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
