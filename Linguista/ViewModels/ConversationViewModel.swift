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
    private let ttsViewModel = TtsViewModel()
    private var isLoading = false
    private var errorMessage: String?
    
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
        conversationSoFar = Utilities.trimMessageArray(completionRequest: conversationSoFar, maxLength: 10)
        
        do {
            let response = try await completionsService.fetchCompletion(completionRequest: conversationSoFar)
            let responseMessage = response.choices?.first?.message ?? Message(role: "error", content: "error")
            let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: false)
            // Add response to message array
            self.messages.append(responseMessageModel)
            
            Task {
                await fetchAndPlayAudio(input: responseMessageModel.message.content) // Pass the plain String
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func fetchAndPlayAudio(input: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let ttsRequest = TtsRequest(model: "tts-1", input: input, voice: "shimmer", speed: 0.9)
            let audioData = try await ttsViewModel.fetchTts(ttsRequest: ttsRequest)
            ttsViewModel.playAudio(with: audioData)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
}
