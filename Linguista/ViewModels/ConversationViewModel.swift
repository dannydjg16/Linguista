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
    private let completionsService = CompletionsService.shared
    
    func sendMessage(completionRequest: CompletionsRequest) async {
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
        
        do {
            
            let response = try await completionsService.fetchCompletion(completionRequest: trimmedConversation)
            let responseMessage = response.choices?.first?.message ?? Message(role: "error", content: "error")
            let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: false)
            DispatchQueue.main.async {
                self.messages.append(responseMessageModel)
            }            
        } catch {
            // Do Error Handling
        }
    }
    
}


