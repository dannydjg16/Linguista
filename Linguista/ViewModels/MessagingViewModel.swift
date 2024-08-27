//
//  MessagingViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 8/20/24.
//

import Foundation

import Combine

class MessagingViewModel: ObservableObject {
    @Published var messages: [MessagingModel] = []
    private let authService = AuthenticationService.shared
    private var cancellable: AnyCancellable?
    @Published var completionResponse: CompletionsResponse?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func sendMessage(completionRequest: CompletionsRequest)  {
        // Add the user's message to the list
        let userMessage = MessagingModel(message: completionRequest.messages.first!, isSentByUser: true)
        messages.append(userMessage)
        
        // Send the message via an API request     
//        Task{
//            do {
//                let response = try await fetchCompletion(completionRequest: completionRequest)
//            } catch{
//                print("Error retrieving completion")
//            }
//        }
        
        //func updateCompletions(with request: CompletionsRequest) {
            Task {
                do {
                    let response = try await fetchCompletionn(completionRequest: completionRequest)
                    // Update the array on the main thread
                    DispatchQueue.main.async {
                        let message = response.choices?.first?.message
                        let messagingResponse = MessagingModel(message: message ?? Message(role: "error", content: "error"), isSentByUser: false)
                        self.messages.append(messagingResponse)
                    }
                } catch {
                    print("Failed to fetch completion: \(error)")
                }
            }
        //}
        
    }
    
//    func fetchCompletion(completionRequest: CompletionsRequest) async throws -> CompletionsResponse {
//        guard let url = URL(string: "https://localhost:7244/openai/completions") else {
//            throw URLError(.badURL)
//        }
//        
//        // https://localhost:7244/openai/completions
//        // https://linguista-appservice.azurewebsites.net/openai/completions
//        
//        let accessToken = authService.getAccessTokenA
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(String(describing: accessToken))", forHTTPHeaderField: "Authorization")
//        
//        do {
//            let jsonData = try JSONEncoder().encode(completionRequest)
//            request.httpBody = jsonData
//        } catch {
//            throw error
//        }
//        
//        isLoading = true
//        errorMessage = nil
//        
//        let (data, _) = try await URLSession.shared.data(for: request)
//        isLoading = false
//        
//        do {
//            let response = try JSONDecoder().decode(CompletionsResponse.self, from: data)
//            return response
//        } catch {
//            throw error
//        }
//    }
    
        deinit {
            cancellable?.cancel()
        }
    
    func fetchCompletionn(completionRequest: CompletionsRequest) async throws -> CompletionsResponse {
        guard let url = URL(string: "https://localhost:7244/openai/completions") else {
            throw URLError(.badURL)
        }

        let accessToken = authService.getAccessTokenA
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(String(describing: accessToken))", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(completionRequest)
            request.httpBody = jsonData
        } catch {
            throw error
        }
        
        isLoading = true
        errorMessage = nil
        
        let session = URLSession(configuration: .default, delegate: CustomSessionDelegate(), delegateQueue: nil)
        
        let (data, _) = try await session.data(for: request)
        isLoading = false
        
        do {
            let response = try JSONDecoder().decode(CompletionsResponse.self, from: data)
            return response
        } catch {
            throw error
        }
    }
}
class CustomSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
