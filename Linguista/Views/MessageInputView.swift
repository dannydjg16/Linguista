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
        HStack {
            TextField("Type a message", text: $speechRecognizer.transcribedText)
                .padding()
                .background(colorScheme == .light ? Color.white : Color.black.opacity(0.5))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.brown.opacity(0.15), lineWidth: 2)
                )
            
            Button("Send") {
                sendMessage()
            }
            .padding()
            .background(Color.brown)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.leading)
        .padding(.trailing)
    }
    
    private func sendMessage() {
        if !speechRecognizer.transcribedText.isEmpty {
            let messages = [
                Message(role: "system", content: "You are teaching an English-speaking person \(Utilities.getLanguageName(by: accountManager.languageToLearn)). Use basic sentences that are not complex, as if you are teaching an infant. Respond in \(Utilities.getLanguageName(by: accountManager.languageToLearn)) unless otherwise instructed by user"),
                Message(role: "user", content: speechRecognizer.transcribedText)
            ]
            let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 100, topP: 1)
            Task {
                await conversationViewModel.sendMessage(completionRequest: dataModel)
            }
            speechRecognizer.transcribedText = ""
        }
    }
    
    private func replyForUser() {
        let messages = [
            Message(role: "system", content: "Answer the last prompt and continue the conversation. Reply in \(Utilities.getLanguageName(by: accountManager.languageToLearn)). Keep sentences very simple, as if you were replying to an infant")]
        
        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 100, topP: 1)
        Task {
            await conversationViewModel.sendMessageForUser(completionRequest: dataModel)
        }
    }
}

struct MessageInputView_Previews: PreviewProvider {
    static var previews: some View {
        MessageInputView(speechRecognizer: SpeechRecognizer())
            .environmentObject(ConversationViewModel())
            .environmentObject(AccountManager())
        
    }
}
