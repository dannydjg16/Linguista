//
//  SpokenMessagingView.swift
//  Linguista
//
//  Created by Daniel Grant on 11/11/24.
//

import Foundation
import SwiftUI

struct SpokenMessagingView: View {
    
    @StateObject private var messagingViewModel = ConversationViewModel()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var currentMessage = ""
    @State private var languageToTranslate = 1
    @State private var textEditorHeight: CGFloat = 20
    
    var body: some View {
        VStack{
            Section{
                
                Picker("Language: ", selection: $languageToTranslate) {
                    ForEach(popularLanguageObjects){ language in
                        Text(language.name).tag(language.id)
                        
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
                .padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 10)
                
            }
            .background(Color.brown.opacity(0.15))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.brown.opacity(0.15), lineWidth: 2))
            
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach($messagingViewModel.messages, id: \.id) { $message in
                            
                            HStack {
                                
                                if message.isSentByUser {
                                    Spacer()
                                    
                                    Text(message.message.content)
                                        .padding()
                                        .multilineTextAlignment(.leading)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.brown.opacity(0.15), lineWidth: 2))
                                } else {
                                    Text(message.message.content)
                                        .padding()
                                        .background(Color.brown.opacity(0.2))
                                        .cornerRadius(10)
                                    
                                    PlayAudioButton(message: message, messagingViewModel: messagingViewModel)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                .onChange(of: $messagingViewModel.messages.count) {
                    // Scroll to the last message when new messages are added
                    if let lastIndex = $messagingViewModel.messages.last?.id {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                }
            }
            HStack {
                SpeechRecognizerView(speechRecognizer: speechRecognizer)
                    .padding()
            }
            HStack {
                TextField("Type a message", text: $speechRecognizer.transcribedText)
                    .frame(height: textEditorHeight)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brown.opacity(0.15), lineWidth: 2))
                    .cornerRadius(8)
                
                Button(action: {
                    
                    if !speechRecognizer.transcribedText.isEmpty {
                        let messages = [Message(role: "system", content: "Pretend you are having a conversation as if you are teaching an English speaking person \(Utilities.getLanguageName(by: languageToTranslate)). Respond in \(Utilities.getLanguageName(by: languageToTranslate))"),
                                        
                                        Message(role: "system", content: "Analyze all messages provided and continue the conversation"),
                                        Message(role: "user", content: "\(speechRecognizer.transcribedText)")]
                        
                        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 100, topP: 1)
                        
                        Task {
                            
                            await messagingViewModel.sendMessage(completionRequest: dataModel)
                        }
                        
                        speechRecognizer.transcribedText = ""
                    }
                }) {
                    Text("\(Utilities.getLanguageName(by: languageToTranslate))")
                        .bold()
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    
                    if !speechRecognizer.transcribedText.isEmpty {
                        let messages = [
                            Message(role: "user", content: "\(speechRecognizer.transcribedText)")]
                        
                        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 100, topP: 1)
                        
                        Task {
                            
                            await messagingViewModel.sendMessage(completionRequest: dataModel)
                        }
                        
                        speechRecognizer.transcribedText = ""
                    }
                }) {
                    Text("English")
                        .bold()
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            
        }
    }
}




struct SpokenMessagingView_Previews: PreviewProvider {
    static var previews: some View {
        SpokenMessagingView()
    }
}
