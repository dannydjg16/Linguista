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
    private let completionsService = CompletionsService.shared
    private var cancellable: AnyCancellable?
    
    func sendMessage(completionRequest: CompletionsRequest) async  {
        
        // Add the user's message to the list
        let userMessage = MessagingModel(message: completionRequest.messages[1], isSentByUser: true)
        messages.append(userMessage)
        
        // Put together list to save messages
        var conversationSoFar = completionRequest
        conversationSoFar.messages = messages.compactMap { $0.message }
        
        // Add system prompt at the beginning of the conversation
        conversationSoFar.messages.insert(completionRequest.messages[0], at: 0)
        
        // Call trimMessageArray to limit the size of the array thats passed in.
        let trimmedConversation = Utilities.trimMessageArray(completionRequest: conversationSoFar, maxLength: 5, savedMessages: 1)
        
        do{
            
            let response = try await completionsService.fetchCompletion(completionRequest: trimmedConversation)
            let responseMessage = response.choices?.first?.message ?? Message(role: "error", content: "error")
            let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: false)
            self.messages.append(responseMessageModel)
            
        } catch {
            // Do Error Handling
        }
        
    }
}
