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
    @ObservedObject var viewModel = MessageViewModel()
    
    
    var body: some View {
        VStack {
            TextField("Enter translation prompt", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

            if let response = viewModel.completionResponse {
                Text("Response ID: \(response.id ?? "N/A")")
                Text("Model: \(response.model ?? "N/A")")
                if let choices = response.choices {
                    ForEach(choices, id: \.self) { choice in
                        Text("Choice: \(choice.message.content)")
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }

            Button(action: {
                postRequest(selectedPrompt: "\(selectedPrompt)", selectedLanguage: "\(selectedLanguage)", userMessage: userInput)
            }) {
                Text("Send Request")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(selectedLanguage: "Farsi", selectedPrompt: "Translate this word")
    }
}

func postRequest(selectedPrompt: String, selectedLanguage: String, userMessage: String) {
    let messages = [Message(role: "system", content: "\(selectedPrompt) in \(selectedLanguage)"), Message(role: "user", content: "gorbeh")]
    let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.2, maxTokens: 10, topP: 1)
    
    guard let url = URL(string: "https://localhost:7244/OpenAi/completions") else {
        print("Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        let jsonData = try JSONEncoder().encode(dataModel)
        request.httpBody = jsonData
    } catch {
        print("Error encoding data: \(error)")
        return
    }

    let session = URLSession(configuration: .default, delegate: CustomSessionDelegate(), delegateQueue: nil)
    let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Invalid response")
            return
        }

        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            print("Response: \(responseString)")
        }
    }

    task.resume()
}
