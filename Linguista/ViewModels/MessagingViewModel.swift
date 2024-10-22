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
    
    func sendMessage(completionRequest: CompletionsRequest) async  {
        
        // Identify System Message for use later
        let systemMessageInRequest = completionRequest.messages[0]
        let systemMessage = MessagingModel(message: completionRequest.messages[0], isSentByUser: true)
        
        // Identify Users Message for use later
        let userMessage = MessagingModel(message: systemMessageInRequest, isSentByUser: true)
        
        
        
        // Add user message to the message array that the user can see.
        // this will also allow the user message to be sent to the ai when messages gets mapped to conversationSoFAr
        //DispatchQueue.main.async {
            self.messages.append(userMessage)
        //}
        
        // Put together list to save messages
        var conversationSoFar = completionRequest
        //
        conversationSoFar.messages = messages.compactMap { $0.message }
        
        // Add system prompt at the beginning of the conversation
        conversationSoFar.messages.insert(systemMessageInRequest, at: 0)
        
        // Call trimMessageArray to limit the size of the array thats passed in.
        let trimmedConversation = Utilities.trimMessageArray(completionRequest: conversationSoFar, maxLength: 5, savedMessages: 1)
        
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
