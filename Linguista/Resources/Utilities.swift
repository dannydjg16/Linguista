//
//  Utilities.swift
//  Linguista
//
//  Created by Daniel Grant on 9/5/24.
//

import Foundation

struct Utilities {
    
    static func getLanguageName(by id: Int) -> String {
        return popularLanguageObjects.first { $0.id == id }!.name
    }
    
    static func trimMessageArray(completionRequest: CompletionsRequest, maxLength: Int, savedMessages: Int) -> CompletionsRequest {
        
        guard completionRequest.messages.count > maxLength else {
            return completionRequest
        }
        
        // Always keep the first two elements
        let firstMessages = completionRequest.messages.prefix(savedMessages)
        
        // Calculate how many elements from the end to keep
        let numberOfElementsFromEnd = maxLength - firstMessages.count
        // Get last elements to send to API
        let lastMessages = completionRequest.messages.suffix(numberOfElementsFromEnd)
        
        // Combine the first and last messages of the array that is being trimmed to make a new array
        let trimmedArray = Array(firstMessages + lastMessages)
        
        // Create new CompletionRequest so that I can alter the message array
        var completionRequestToReturn = completionRequest
        // Attach trimmed list to Completion Request
        completionRequestToReturn.messages = trimmedArray
        
        return completionRequestToReturn
    }
    
    // This will be the function overload to filter out by system messages and save those
    static func trimMessageArray(completionRequest: CompletionsRequest, maxLength: Int) -> CompletionsRequest {
        
        guard completionRequest.messages.count > maxLength else {
            return completionRequest
        }
        
        let systemMessageCount = 0
        
        // Always keep the system elements
        let firstMessages = completionRequest.messages.prefix(systemMessageCount)
        
        // Calculate how many elements from the end to keep
        let numberOfElementsFromEnd = maxLength - firstMessages.count
        // Get last elements to send to API
        let lastMessages = completionRequest.messages.suffix(numberOfElementsFromEnd)
        
        // Combine the first and last messages of the array that is being trimmed to make a new array
        let trimmedArray = Array(firstMessages + lastMessages)
        
        // Create new CompletionRequest so that I can alter the message array
        var completionRequestToReturn = completionRequest
        // Attach trimmed list to Completion Request
        completionRequestToReturn.messages = trimmedArray
        
        return completionRequestToReturn
    }
}
