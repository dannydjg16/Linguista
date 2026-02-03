//
//  MessageInputView.swift
//  Linguista
//
//  Created by Daniel Grant on 1/15/25.
//

import Foundation
import SwiftUI

struct MessageInputView: View {
    
    @EnvironmentObject var accountManager: AccountManager
    @EnvironmentObject var conversationViewModel: ConversationViewModel
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        VStack(spacing: 8) {
            // Text input field
            HStack {
                TextField("Type a message", text: $speechRecognizer.transcribedText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding()
                    .background(colorScheme == .light ? Color.white : Color.black.opacity(0.5))
                    .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brown, lineWidth: 2)
                    )
                    .onSubmit {
                        sendMessageGetTranslation()
                    }
                    .autocorrectionDisabled()
                
                if !speechRecognizer.transcribedText.isEmpty {
                    Button(action: {
                        sendMessageGetTranslation()
                        print("Sending: \(speechRecognizer.transcribedText)")
                        speechRecognizer.transcribedText = ""
                    }) {
                        Image(systemName: "arrow.up.message")
                            .padding(8)
                            .background(Circle().fill(.brown))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 8)
                }
            }
            .padding()
            
            // Toolbar buttons
            HStack {
                
                if !speechRecognizer.transcribedText.isEmpty {
                    Text("Response: ")
                    
                    Button("English") {
                        sendMessageGetEnglish()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("\(Utilities.getLanguageName(by: accountManager.languageToLearn))") {
                        sendMessageGetTranslation()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Text("|")
                    
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
                
                
            }
            .padding(.horizontal)
        }
        .padding(.leading)
        .padding(.trailing)
    }
    
    private func sendMessageGetEnglish() {
        
        if !speechRecognizer.transcribedText.isEmpty {
            let messages = [
                Message(role: "system", content: "Continue the conversation with the user. You are giving a lesson about numbers. Respond with a maximum of 10-15 words. The words should be very informal like just chatting."),
                Message(role: "user", content: speechRecognizer.transcribedText)
            ]
            
            let dataModel = CompletionsRequest(model: "gpt-4o-mini", messages: messages, maxTokens: 100, topP: 1)
            
            Task {
                await conversationViewModel.sendMessage(completionRequest: dataModel)
            }
        }
    }
    
    private func sendMessageGetTranslation() {
        
        let languageToLearn = Utilities.getLanguageName(by: accountManager.languageToLearn)
        
        if !speechRecognizer.transcribedText.isEmpty {
            let messages = [
                Message(role: "system", content: "Continue the conversation with the user. You are giving a lesson about numbers. Respond with a maximum of 10-15 words. The words should be very informal like just chatting. Respond in \(languageToLearn)"),
                Message(role: "user", content: speechRecognizer.transcribedText)
            ]
            
            let dataModel = CompletionsRequest(model: "gpt-4o-mini", messages: messages, maxTokens: 100, topP: 1)
            
            Task {
                await conversationViewModel.sendMessage(completionRequest: dataModel)
            }            
        }
    }
}

struct MessageInputView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        
        MessageInputView()
            .environmentObject(ConversationViewModel())
            .environmentObject(AccountManager(context: context))
            .environmentObject(SpeechRecognizer())
    }
}
