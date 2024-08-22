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
    
    func sendMessage(completionRequest: CompletionsRequest) async {
        // Add the user's message to the list
        let userMessage = MessagingModel(message: completionRequest.messages.first!, isSentByUser: true)
        messages.append(userMessage)
        
        // Send the message via an API request     
        Task{
            do {
                let response = try await fetchCompletion(completionRequest: completionRequest)
            } catch{
                print("Error retrieving completion")
            }
        }
        
        
    }
    
    private func sendRequest(text: String) {
        // Mocked API request. Replace with actual API call.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let responseText = "Response to: \(text)"
            let responseMessage = Message(text: responseText, isSentByUser: false)
            self.messages.append(responseMessage)
        }
        
        
        
        
    }
    
    func fetchCompletion(completionRequest: CompletionsRequest) async throws -> CompletionsResponse {
        guard let url = URL(string: "https://localhost:7244/openai/completions") else {
            throw URLError(.badURL)
        }
        
        // https://localhost:7244/openai/completions
        // https://linguista-appservice.azurewebsites.net/openai/completions
        
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
        
        let (data, _) = try await URLSession.shared.data(for: request)
        isLoading = false
        
        do {
            let response = try JSONDecoder().decode(CompletionsResponse.self, from: data)
            return response
        } catch {
            throw error
        }
    }
    
        deinit {
            cancellable?.cancel()
        }
}
