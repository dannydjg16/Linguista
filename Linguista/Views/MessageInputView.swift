//
//  MessageInputView.swift
//  Linguista
//
//  Created by Daniel Grant on 1/15/25.
//

import Foundation
import SwiftUI

struct MessageInputView: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @Binding var languageToTranslate: Int
    @ObservedObject var messagingViewModel: ConversationViewModel

    var body: some View {
        HStack {
            TextField("Type a message", text: $speechRecognizer.transcribedText)
                .padding()
                .background(Color.white)
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
    }

    private func sendMessage() {
        if !speechRecognizer.transcribedText.isEmpty {
            let messages = [
                Message(role: "system", content: "You are teaching an English-speaking person \(Utilities.getLanguageName(by: languageToTranslate)). Use very basic sentences that are not complex. Respond in \(Utilities.getLanguageName(by: languageToTranslate)) unless otherwise instructed."),
                Message(role: "user", content: speechRecognizer.transcribedText)
            ]
            let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 100, topP: 1)
            Task {
                await messagingViewModel.sendMessage(completionRequest: dataModel)
            }
            speechRecognizer.transcribedText = ""
        }
    }
}


struct MessageInputView_Previews: PreviewProvider {
    static var previews: some View {
        MessageInputView(speechRecognizer: SpeechRecognizer(), languageToTranslate: .constant(1), messagingViewModel: ConversationViewModel())
    }
}
