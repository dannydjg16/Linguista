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
        
        // Add the user's message to the list
        let userMessage = MessagingModel(message: completionRequest.messages[1], isSentByUser: true)
        
        //DispatchQueue.main.async {
            self.messages.append(userMessage)
        //}
        
        // Put together list to save messages
        var conversationSoFar = completionRequest
        // Here, completionRequest has what is sent over from the view. This is the instruction to the system and the user message.
            // It does NOT have the message above(the one to the user. Im not sure if this one is needed)
        
        
        // What is needed to send to open ai
            // Definitely the original system message every time. SHould be at the top. This is the most important instruction for the ai.
            
            //
        
        // Conversation so far went from 2 items to 1 here. user message was removed.
            // Below, at this point(when screen first used, "messages" only has the message above.)
        conversationSoFar.messages = messages.compactMap { $0.message }
        
        // Add system prompt at the beginning of the conversation
        conversationSoFar.messages.insert(completionRequest.messages[0], at: 0)
        
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
