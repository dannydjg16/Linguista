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
            
            LanguagePickerView(languageToTranslate: $languageToTranslate)
            
            MessageListView(messagingViewModel: messagingViewModel)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            //SpeechRecognizerView(speechRecognizer: speechRecognizer)
                //.padding()
            
            MessageInputView(
                            speechRecognizer: speechRecognizer,
                            languageToTranslate: $languageToTranslate,
                            messagingViewModel: messagingViewModel
                        )
                        .padding()
            
//            HStack {
//                TextField("Type a message", text: $speechRecognizer.transcribedText)
//                    .frame(height: textEditorHeight)
//                    .padding()
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.brown.opacity(0.15), lineWidth: 2))
//                    .cornerRadius(8)
//                
//                Button(action: {
//                    
//                    if !speechRecognizer.transcribedText.isEmpty {
//                        let messages = [Message(role: "system", content: "You are having a conversation where you are teaching an English speaking person how to speak \(Utilities.getLanguageName(by: languageToTranslate)). Respond in \(Utilities.getLanguageName(by: languageToTranslate))", additionalContent: "nullString"),
//                                        
//                                        Message(role: "system", content: "Analyze all messages provided and continue the conversation", additionalContent: "nullString"),
//                                        Message(role: "user", content: "\(speechRecognizer.transcribedText)", additionalContent: "nullString")]
//                        
//                        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 100, topP: 1)
//                        
//                        Task {
//                            await messagingViewModel.sendMessage(completionRequest: dataModel)
//                        }
//                        
//                        speechRecognizer.transcribedText = ""
//                    }
//                }) {
//                    Text("\(Utilities.getLanguageName(by: languageToTranslate))")
//                        .bold()
//                        .padding()
//                        .background(Color.brown)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                Button(action: {
//                    
//                    if !speechRecognizer.transcribedText.isEmpty {
//                        let messages = [
//                            Message(role: "user", content: "\(speechRecognizer.transcribedText)", additionalContent: "nullString")]
//                        
//                        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 100, topP: 1)
//                        
//                        Task {
//                            await messagingViewModel.sendMessage(completionRequest: dataModel)
//                        }
//                        
//                        speechRecognizer.transcribedText = ""
//                    }
//                }) {
//                    Text("English")
//                        .bold()
//                        .padding()
//                        .background(Color.brown)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//            }
//            .padding()
//
            
        }
    }
}

struct SpokenMessagingView_Previews: PreviewProvider {
    static var previews: some View {
        SpokenMessagingView()
    }
}
