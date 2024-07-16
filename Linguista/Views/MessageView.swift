//
//  MessageView.swift
//  Linguista
//
//  Created by Daniel Grant on 7/10/24.
//

import Foundation
import SwiftUI

struct MessageView: View {
    @ObservedObject var viewModel = MessageViewModel()
    
    var body: some View {
        VStack {
            Text("Completion Request Example")
                .font(.title)
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
                postRequest()
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
        MessageView()
    }
}

func postReqnmuest() {
    // Your local IP address and endpoint
    guard let url = URL(string: "https://localhost:7244/OpenAi/completions") else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let messages = [Message(role: "system", content: ""), Message(role: "user", content: "")]
    let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: [], temperature: 0.2, maxTokens: 10, topP: 10)

    
    do {
        let jsonData = try JSONEncoder().encode(dataModel)
        request.httpBody = jsonData
    } catch {
        print("Error encoding data: \(error)")
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
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

class CustomSessionnDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

func postRequest() {
    guard let url = URL(string: "https://localhost:7244/OpenAi/completions") else {
        print("Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    //let dataModel = CompletionsRequest(model: "", messages: [], temperature: 0.2, maxTokens: 10, topP: 10)
    let messages = [Message(role: "system", content: <#T##String#>), Message(role: "user", content: <#T##String#>)]
    let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: [], temperature: 0.2, maxTokens: 10, topP: 10)
    
    
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
