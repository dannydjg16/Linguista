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
    
    static func recalculateHeight(height: CGFloat, text: String) -> CGFloat {
        // Use a method to calculate how many lines of text there are
        let numberOfLines = text.split(separator: "\n").count
        let lineHeight: CGFloat = 20 // Approximate line height
        let newHeight = max(40, CGFloat(numberOfLines) * lineHeight) // 40 is the min height
        return min(newHeight, 200) // Limit to max height of 200, adjust as needed
    }
    
    static func trimMessageArray(completionRequest: CompletionsRequest, maxLength: Int, savedMessages: Int) -> CompletionsRequest {
        
        guard completionRequest.messages.count > maxLength else {
            return completionRequest
        }
        
        // Always keep the first two elements
        let firstMessages = completionRequest.messages.prefix(savedMessages)
        
        // Calculate how many elements from the end to keep
        let elementsFromEnd = maxLength - firstMessages.count
        // Get last elements to send to API
        let lastElements = completionRequest.messages.suffix(elementsFromEnd)
        // combine the first and last parts of the array
        let trimmedArray = Array(firstMessages + lastElements)
        
        
        var completionRequestToReturn = completionRequest
        // Attach trimmed list to Completion Request
        completionRequestToReturn.messages = trimmedArray
        
        return completionRequestToReturn
    }
}
