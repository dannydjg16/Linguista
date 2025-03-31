//
//  ConversationViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 9/5/24.
//

import Foundation
import Combine

@MainActor
class ConversationViewModel: ObservableObject, Sendable {
    
    @Published var messages: [MessagingModel] = [MessagingModel(message: Message(role: "system", content: "\(conversationStarters[Int.random(in: 0..<conversationStarters.count)])"), isSentByUser: false) ]
    //, MessagingModel(message: Message(role: "user", content: "Hello"), isSentByUser: true)
    
    private let completionsService = CompletionsService.shared
    private let ttsViewModel = TtsViewModel()
    private var isLoading = false
    private var errorMessage: String?
    
    func makeNewChatWithNewPrompt() {
        messages = [MessagingModel(message: Message(role: "system", content: "\(conversationStarters[Int.random(in: 0..<conversationStarters.count)])"), isSentByUser: false)]
    }
    
    func resetChatWithSamePrompt() {
        messages = Array(messages.prefix(1))
    }
    
    func sendMessage(completionRequest: CompletionsRequest) async {
        
        if (completionRequest.messages.count == 0){
            return
        }
        
        // Identify System Message for use later
        let systemMessage = completionRequest.messages.filter{ $0.role == "system" }.first
        
        // Identify Users Message for use later
        let userMessage = MessagingModel(message: completionRequest.messages.last!, isSentByUser: true)
        
        // Add user message to the message array
        await MainActor.run {
            self.messages.append(userMessage)
        }
        
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
            
            Task {
                let messageModelWithAudio = await fetchAndPlayAudio(messagingModel: responseMessageModel)
                // Add response with audio to message array
                await MainActor.run {
                    self.messages.append(messageModelWithAudio)
                }
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Same functionality as sendMessageForUser EXCEPT this one does not add the original message into the messages array.
    func sendMessageForUser(completionRequest: CompletionsRequest) async {
        
        if (completionRequest.messages.count == 0){
            return
        }
        
        // Identify System Message for use later
        let systemMessage = completionRequest.messages.filter{ $0.role == "system" }.first
        
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
            let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: true)
            
            Task {
                let messageModelWithAudio = await fetchAndPlayAudio(messagingModel: responseMessageModel)
                // Add response with audio to message array
                await MainActor.run {
                    self.messages.append(messageModelWithAudio)
                }
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func sendMessageGetMessage(completionRequest: CompletionsRequest) async -> MessagingModel? {
        
        if (completionRequest.messages.count == 0){
            return nil
        }
        
        do {
            let response = try await completionsService.fetchCompletion(completionRequest: completionRequest)
            let responseMessage = response.choices?.first?.message ?? Message(role: "error", content: "error")
            let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: true)
            
            return responseMessageModel
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func sendMessageGetMessageTest(completionRequest: CompletionsRequest) async -> MessagingModel? {
        
        let responseMessage = Message(role: "system", content: "Translate the word or sentence from Farsi to English or English to Farsi based on what is provided.")
        let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: true, translatedMessageContent: "translatedMessageContent")
                
        return responseMessageModel
    }
    
    func setTranslatedMessage(messagingModel: MessagingModel) -> Bool {
        
        if let index = messages.firstIndex(where: { $0.id == messagingModel.id }) {
            if (self.messages[index].translatedMessageContent == nil) {
                self.messages[index].translatedMessageContent = messagingModel.translatedMessageContent
            }
            
            if (self.messages[index].audioData == nil) {
                self.messages[index].audioData = messagingModel.audioData
            }
        }
        
        return true
    }
    
    func getTranslationMessage(messagingModel: MessagingModel) async {
        
        
        let messagesForCompletionRequest = [Message(role: "system", content: "Translate the word or sentence from Farsi to English or English to Farsi based on what is provided."), Message(role: "user", content: "\(messagingModel.message.content)")]
        let dataModel = CompletionsRequest(model: "gpt-3.5-turbo", messages: messagesForCompletionRequest, temperature: 0.2, maxTokens: 10, topP: 1)
        
        
        if let index = messages.firstIndex(where: { $0.id == messagingModel.id }) {
            await MainActor.run {
                self.messages[index].translatedMessageContent = "Hey"
            }
        }
        
        //        do {
        //            let response = try await completionsService.fetchCompletion(completionRequest: dataModel)
        //            let responseMessage = response.choices?.first?.message ?? Message(role: "error", content: "error")
        //            let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: true)
        //
        //            if let index = messages.firstIndex(where: { $0.id == messagingModel.id }) {
        //                messages[index].translatedMessageContent = responseMessageModel.message.content
        //            }
        
        //        } catch {
        //            print("Error: \(error.localizedDescription)")
        
    }
    
    func fetchAndPlayAudio(messagingModel: MessagingModel) async -> MessagingModel {
        
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
    
    func fetchAndPlayAudioForMessagingModal(messagingModel: MessagingModel) async -> MessagingModel {
        
        isLoading = true
        errorMessage = nil
        
        var updatedMessagingModel = messagingModel
        
        do {
            let ttsRequest = TtsRequest(model: "tts-1-hd", input: messagingModel.translatedMessageContent!, voice: "shimmer", speed: 0.8)
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
