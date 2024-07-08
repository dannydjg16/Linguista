//
//  MessageView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/27/24.
//

import Foundation
import SwiftUI

struct MessageView: View {
    let selectedLanguage: String
    let selectedPrompt: String
    
    @State private var systemPrompt = ""
    @State private var messageText = ""
    @State private var messageLog: [String] = []
    @State private var message1 = Message(role: "system", content: "")
    @State private var message2 = Message(role: "user", content: "")
    //@State private var messages: [Message] = [message1, message2]
    lazy var completionReq = CompletionsRequest(model: "gpt-3.5-turbo", messages: [message1, message2], temperature: 0.2, maxTokens: 20, topP: 1)
    
    
    let completionService = CompletionService()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messageLog, id: \.self) { message in
                        Text(message)
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(100)
                            .padding(.horizontal, 10)
                    }
                }
            }
            .frame(maxHeight: 300)

            HStack {
                TextField("Enter your message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: sendMessage) {
                    Text("Send")
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(100)
                }
                .padding(.trailing)
            }
            .padding()
        }
        .background(Color.gray)
        .navigationTitle("\(selectedPrompt): \(selectedLanguage)")
    }

    private mutating func sendMessage() {
        if !messageText.isEmpty {
            messageLog.append(messageText)
            messageText = ""
            
            // Call your service here, for example:
            completionService.sendRequest(completionRequest: completionReq)
        }
    }
}

// Example BlankService class (hypothetical)
class BlankService {
    func call() {
        // Implementation of your service logic
        print("Calling BlankService...")
        
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(selectedLanguage: "flsakdfjsadlkfj",selectedPrompt: "hh")
    }
}
