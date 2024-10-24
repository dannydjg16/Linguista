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
    private let completionsService = CompletionsService.shared
    
    // Might be best to handle this stuff in two parts. 1 to handle the display stuff for the user and 1 to handle the api stuff.
    func sendMessage(completionRequest: CompletionsRequest) async  {
        
        if (completionRequest.messages.count == 0){
            return
        }
        // Identify System Message for use later
        let systemMessage = completionRequest.messages.filter{ $0.role == "system" }.first
        
        // Identify Users Message for use later
        let userMessage = MessagingModel(message: completionRequest.messages.last!, isSentByUser: true)
        
        // Add user message to the message array that the user can see.
        self.messages.append(userMessage)
        
        // Put together list to save messages
        var conversationSoFar = completionRequest
        
        // Keep completion request data, but update the message array to pass forward.
        conversationSoFar.messages = messages.compactMap { $0.message }
        
        // Add system prompt at the beginning of the conversation
        conversationSoFar.messages.insert(systemMessage ?? completionRequest.messages[0], at: 0)
        
        // Call trimMessageArray to limit the size of the array thats passed in.
        conversationSoFar = Utilities.trimMessageArray(completionRequest: conversationSoFar, maxLength: 5)
        
        do {
            let response = try await completionsService.fetchCompletion(completionRequest: conversationSoFar)
            let responseMessage = response.choices?.first?.message ?? Message(role: "error", content: "error")
            let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: false)
            // Add response to message array
            self.messages.append(responseMessageModel)
            
        } catch {
            // Do Error Handling
        }
    }
}
