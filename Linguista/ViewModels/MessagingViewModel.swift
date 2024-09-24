//
//  MessagingViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 8/20/24.
//

import Foundation
import Combine

class MessagingViewModel: ObservableObject {
    
    @Published var messages: [MessagingModel] = [MessagingModel(message: Message(role: "user", content: "Hello! Send us a word or sentence and we will translate it for you."), isSentByUser: false)]
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
        
        let trimmedConversation = trimMessageArray(completionRequest: conversationSoFar, maxLength: 4)
        
        // This gets the completion response and adds that message to the array of messages(which ends up getting displayed by the view)
        fetchCompletion(completionRequest: trimmedConversation)
    }
    
    func trimMessageArray(completionRequest: CompletionsRequest, maxLength: Int) -> CompletionsRequest {
        guard completionRequest.messages.count > maxLength else {
            return completionRequest
        }
        
        // Always keep the first two elements
        let firstTwo = completionRequest.messages.prefix(2)
        
        // Calculate how many elements from the end to keep
        let elementsFromEnd = maxLength - firstTwo.count
        let lastElements = completionRequest.messages.suffix(elementsFromEnd)
        let trimmedArray = Array(firstTwo + lastElements)
        
        var completionRequestToReturn = completionRequest
        // Attach trimmed list to Completion Request
        completionRequestToReturn.messages = trimmedArray
        
        return completionRequestToReturn
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
