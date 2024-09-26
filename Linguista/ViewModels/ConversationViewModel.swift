//
//  ConversationViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 9/5/24.
//

import Foundation

import Combine

class ConversationViewModel: ObservableObject {
    
    @Published var messages: [MessagingModel] = [MessagingModel(message: Message(role: "user", content: "Let's have a conversation. If you have any questions, feel free to ask!"), isSentByUser: false), MessagingModel(message: Message(role: "user", content: "How has your day been?"), isSentByUser: false)]
    
    @Published var errorMessage: String?
    @Published var isLoading = false
    private let authService = AuthenticationService.shared
    private var cancellable: AnyCancellable?
    
    func sendMessage(completionRequest: CompletionsRequest)  {
        
        // Add the user's message to the list
        let userMessage = MessagingModel(message: completionRequest.messages[1], isSentByUser: true)
        messages.append(userMessage)
        
        // Put together list to save messages
        var conversationSoFar = completionRequest
        conversationSoFar.messages = messages.compactMap { $0.message }
        
        // Add system prompt at the beginning of the conversation
        conversationSoFar.messages.insert(completionRequest.messages[0], at: 0)
        
        // Call trimMessageArray to limit the size of the array thats passed in.
        let trimmedConversation = Utilities.trimMessageArray(completionRequest: conversationSoFar, maxLength: 10, savedMessages: 1)
        
        // This gets the completion response and adds that message to the array of messages(which ends up getting displayed by the view)
        fetchCompletion(completionRequest: trimmedConversation)
    }
    
    func fetchCompletion(completionRequest: CompletionsRequest) {
        
        guard let url = URL(string: "https://localhost:7244/openai/completions") else { return }
        // https://localhost:7244/openai/completions
        // https://linguista-appservice.azurewebsites.net/openai/completions
        
        authService.getAccessToken { [weak self] accessToken in
            guard let self = self, let accessToken = accessToken else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to retrieve access token"
                }
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            do {
                let jsonData = try JSONEncoder().encode(completionRequest)
                request.httpBody = jsonData
            } catch {
                self.errorMessage = "Failed to encode requset: \(error.localizedDescription)"
                return
            }
            
            isLoading = true
            errorMessage = nil
            
            let session = URLSession(configuration: .default, delegate: URLSessionPinningDelegate(), delegateQueue: nil)
            
            cancellable = session.dataTaskPublisher(for: request)
                .map { $0.data }
                .decode(type: CompletionsResponse.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    self.isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }, receiveValue: { response in
                    let responseMessage = response.choices?.first?.message ?? Message(role: "error", content: "error")
                    let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: false)
                    self.messages.append(responseMessageModel)
                })
        }
    }
        deinit {
            cancellable?.cancel()
        }
}
