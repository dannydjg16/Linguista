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
    @State private var isLoadingAudio = false
    @State private var isLoadingTranslation = false
    @State private var isLoadingTranslatedAudio = false
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
                
                InfoSection(title: "Audio") {
                        MessageBubbleViewWithoutPlayAudioButton(message: message.message.content)
                    }
                }
            
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

                
                InfoSection(title: "Audio") {
                    if let audioData = message.audioData {
                        AudioPlayerView(audioManager: AudioPlayerManager(audioData: audioData))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        if isLoadingAudio {
                            HStack {
                                ProgressView()
                                Text("Loading audio…")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Button(action: { Task { isLoadingAudio = true; defer { isLoadingAudio = false }; await getAudioMessage(messageToGetAudioFor: message) } }) {
                                Label("Load Audio", systemImage: "waveform")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.brown)
                            .disabled(isLoadingAudio)
                        }
                    }
                }
                .animation(.easeInOut, value: message.audioData != nil)
                
                InfoSection(title: "Translation") {
                    if let translatedContent = message.translatedMessageContent {
                        MessageBubbleViewWithoutPlayAudioButton(message: translatedContent)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        if isLoadingTranslation {
                            HStack {
                                ProgressView()
                                Text("Translating…")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Button(action: { Task { isLoadingTranslation = true; defer { isLoadingTranslation = false }; await translateWithViewModel(messageToTranslate: message) } }) {
                                Label("Get Translation", systemImage: "text.bubble")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.brown)
                            .disabled(isLoadingTranslation)
                        }
                    }
                }
                .animation(.easeInOut, value: message.translatedMessageContent != nil)

                
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
                
                InfoSection(title: "Translation Audio") {
                    if let translatedMessageAudio = message.translatedAudioData {
                        AudioPlayerView(audioManager: AudioPlayerManager(audioData: translatedMessageAudio))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        if isLoadingTranslatedAudio {
                            HStack {
                                ProgressView()
                                Text("Generating audio…")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Button(action: {
                                if message.translatedMessageContent != nil {
                                    Task { isLoadingTranslatedAudio = true; defer { isLoadingTranslatedAudio = false }; await getAudioMessageForTranslatedMessage(messageToGetAudioFor: message) }
                                } else {
                                    showWarning = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showWarning = false
                                    }
                                }
                            }) {
                                Label("Get Audio", systemImage: "waveform")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.brown)
                            .disabled(isLoadingTranslatedAudio)
                        }
                    }
                }
                .animation(.easeInOut, value: message.translatedAudioData != nil)
            }
        }
    
    @MainActor func translateWithViewModel(messageToTranslate: MessagingModel) async {
        let messages = [Message(role: "system", content: "Translate the word or sentence from \(Utilities.getLanguageName(by: accountManager.languageToLearn)) to English if \(Utilities.getLanguageName(by: accountManager.languageToLearn)) is provided. The translation should be very informal like chatting with an infant. Otherwise, translate from English to \(Utilities.getLanguageName(by: accountManager.languageToLearn)) if English is provided."), Message(role: "user", content: "\(messageToTranslate.message.content)")]
        let dataModel = CompletionsRequest(model: selectedCompletionsModel, messages: messages, maxTokens: maxCompletionTokens, topP: 1)
        
        message.translatedMessageContent = await conversationViewModel.sendMessageGetMessageString(completionRequest: dataModel)
    }
    
    @MainActor func getAudioMessage(messageToGetAudioFor: MessagingModel) async {
        message.audioData = await conversationViewModel.fetchAndPlayAudioReturnData(messageToConvertAndPlay: messageToGetAudioFor.message.content)
    }
    
    @MainActor func getAudioMessageForTranslatedMessage(messageToGetAudioFor: MessagingModel) async {
        message.translatedAudioData = await conversationViewModel.fetchAndPlayAudioReturnData(messageToConvertAndPlay: messageToGetAudioFor
            .translatedMessageContent!)
    }
}

struct MessageModalView_Previews: PreviewProvider {
    
    @State static var message: MessagingModel = MessagingModel(message: Message(role: "aaa", content: "bbb"), isSentByUser: true)
    
    static var previews: some View {
        MessageModalView(message: $message)
    }
}

