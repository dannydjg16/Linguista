//
//  MessageView.swift
//  Linguista
//
//  Created by Daniel Grant on 7/10/24.
//

import Foundation
import SwiftUI

struct MessageView: View {
    let selectedLanguage: String
    let selectedPrompt: String
    @State private var userInput: String = ""
    @StateObject var viewModel = MessageViewModel()
    
    
    var body: some View {
        VStack {
            TextField("Enter translation prompt", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let response = viewModel.completionResponse {
                if let choices = response.choices {
                    ForEach(choices, id: \.self) { choice in
                        Text("'\(userInput)' translates to: \(choice.message.content)")
                    }
                }
            }
            
            Button(action: {
                let messages = [Message(role: "system", content: "\(selectedPrompt) \(selectedLanguage)"), Message(role: "user", content: "\(userInput)")]
                let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
                viewModel.fetchCompletion(completionRequest: dataModel)
            }) {
                Text("Send Request")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }}
            .padding()
            .navigationTitle("\(selectedPrompt) \(selectedLanguage)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }


struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(selectedLanguage: "Farsi", selectedPrompt: "Translate this word")
    }
}
