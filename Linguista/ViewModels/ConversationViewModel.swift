//
//  ConversationViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 9/5/24.
//

import Foundation
import Combine

class ConversationViewModel: ObservableObject {
    
    @Published var messages: [MessagingModel] = [MessagingModel(message: Message(role: "system", content: "Let's have a conversation. If you have any questions, feel free to ask!", additionalContent: "nullString"), isSentByUser: false)]
    
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
            let responseMessage = response.choices?.first?.message ?? Message(role: "error", content: "error", additionalContent: "nullString")
            let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: false)
            
            Task {
                let messageModelWithAudio = await fetchAndPlayAudio(messagingModel: responseMessageModel)
                // Add response to message array
                self.messages.append(messageModelWithAudio)
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func fetchAndPlayAudio(messagingModel: MessagingModel) async -> MessagingModel {
        
        isLoading = true
        errorMessage = nil
        
        var updatedMessagingModel = messagingModel
        
        do {
            let ttsRequest = TtsRequest(model: "tts-1-hd", input: messagingModel.message.content, voice: "shimmer", speed: 0.8)
            let audioData = try await ttsViewModel.fetchTts(ttsRequest: ttsRequest)
            ttsViewModel.playAudio(with: audioData)
            updatedMessagingModel.audioData = audioData
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        
        return updatedMessagingModel
    }
    
    public func playAudio(messagingModel: MessagingModel){
        if let audioData = messagingModel.audioData {
            ttsViewModel.playAudio(with: audioData )
        }
    }
    
    public func playAudio(messagingModel: MessagingModel, speed: Float){
        if let audioData = messagingModel.audioData {
            ttsViewModel.playAudio(with: audioData, speed: speed )
        }
    }
}
