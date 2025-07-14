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
//        HStack {
//            TextField("Type a message", text: $speechRecognizer.transcribedText)
//                .padding()
//                .background(colorScheme == .light ? Color.white : Color.black.opacity(0.5))
//                .cornerRadius(10)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.brown.opacity(0.15), lineWidth: 2)
//                )
//                .autocorrectionDisabled()
//            
//            Button("Send") {
//                sendMessage()
//            }
//            .padding()
//            .background(Color.brown)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//        }
//        .padding(.leading)
//        .padding(.trailing)
        
        
        
//        VStack(spacing: 8) {
//            HStack(spacing: 8) {
//                Button("1") {
//                    // Action for button 1
//                }
//                .padding()
//                .background(Color.brown)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//                
//                Button("2") {
//                    // Action for button 2
//                }
//                .padding()
//                .background(Color.brown)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//                
//                Button("Send") {
//                    // Action for button 3
//                    sendMessage()
//                }
//                .padding()
//                .background(Color.brown)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//            }
//            
//            TextField("Type a message", text: $speechRecognizer.transcribedText, axis: .vertical)
//                .lineLimit(1...5) // Adjust min/max lines as needed
//                .padding()
//                .background(colorScheme == .light ? Color.white : Color.black.opacity(0.5))
//                .cornerRadius(10)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.brown.opacity(0.15), lineWidth: 2)
//                )
//                .autocorrectionDisabled()
//        }
//        .padding(.leading)
//        .padding(.trailing)
        GeometryReader { geometry in
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Button("Button 1") {
                        // Action for button 1
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Button 2") {
                        // Action for button 2
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Button 3") {
                        // Action for button 3
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .frame(width: geometry.size.width)
                
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
                    .frame(width: geometry.size.width)
            }
            .padding(.leading)
            .padding(.trailing)
        }
    }
    
    private func sendMessage() {
        
        var languageToLearn = Utilities.getLanguageName(by: accountManager.languageToLearn)
        
        if !speechRecognizer.transcribedText.isEmpty {
            let messages = [
                Message(role: "system", content: "Continue the conversation with the user. You are giving a lesson about numbers. Respond with a maximum of 10-15 words. The words should be very informal like just chatting."),
                //                Message(role: "system", content: "You are teaching an English-speaking person \(languageToLearn). This is a  lesson about animals. Continue the lesson answering user questions and making new lesson points. Use very very basic sentences that are not complex. Respond in \(languageToLearn) unless otherwise instructed by user."),
                //                Message(role: "system", content: "You are teaching an English-speaking person \(Utilities.getLanguageName(by: accountManager.languageToLearn)). Use basic and short sentences that are not complex, as if you are teaching someone who knows no \(Utilities.getLanguageName(by: accountManager.languageToLearn)). Sometimes ask questions but mostly try and organically respond. Respond in \(Utilities.getLanguageName(by: accountManager.languageToLearn)) unless otherwise instructed by user. Respond with a maximum of 10 words."),
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
