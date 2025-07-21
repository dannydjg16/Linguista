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
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        VStack(spacing: 8) {
            HStack {
                Button("Reply") {
                    // Auto reply?
                }
                .padding()
                .frame(maxWidth: .infinity) // Makes each button take equal width
                .background(Color.brown)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("English") {
                    sendMessageGetEnglish()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.brown)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("\(Utilities.getLanguageName(by: accountManager.languageToLearn))") {
                    sendMessageGetTranslation()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.brown)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity)
            
            TextField("Type a message", text: $speechRecognizer.transcribedText, axis: .vertical)
                .lineLimit(1...5)
                .padding()
                .background(colorScheme == .light ? Color.white : Color.black.opacity(0.5))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.brown.opacity(0.15), lineWidth: 2)
                )
                .autocorrectionDisabled()
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
            speechRecognizer.transcribedText = ""
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
            speechRecognizer.transcribedText = ""
        }
    }
}

struct MessageInputView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        
        MessageInputView(speechRecognizer: SpeechRecognizer())
            .environmentObject(ConversationViewModel())
            .environmentObject(AccountManager(context: context))
    }
}
