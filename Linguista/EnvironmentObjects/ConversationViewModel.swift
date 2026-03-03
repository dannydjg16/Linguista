//
//  ConversationViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 9/5/24.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ConversationViewModel: ObservableObject, Sendable {
    
    //@Published var messages: [MessagingModel] = [MessagingModel(message: Message(role: "system", content: "\(conversationStarters[Int.random(in: 0..<conversationStarters.count)])"), isSentByUser: false) ]
    @Published var messages: [MessagingModel] = [MessagingModel(message: Message(role: "system", content: "Hey there! I am Wista, your personal multi-lingual journal. What is on your mind?"), isSentByUser: false) ]
    private let completionsService = CompletionsService.shared
    private let ttsViewModel = TtsViewModel()
    private var isLoading = false
    private var errorMessage: String?
    @EnvironmentObject var accountManager: AccountManager
    
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
        
        // Put together list to save messages. completionRequest is a model that has messages list.
        var conversationSoFar = completionRequest
        
        // Keep completion request data, but update the message array to pass forward.
        conversationSoFar.messages = messages.compactMap { $0.message }
        
        // Add system prompt at the beginning of the conversation
        conversationSoFar.messages.insert(systemMessage ?? completionRequest.messages[0], at: 0)
        
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
    
    // This one does not have any object passed in. The messages array is made in this method as opposed to the view.
    func sendMessageForUser() async {
        
        let messages = [
            Message(role: "system", content: "You are having a conversation. Continue the conversation in \(Utilities.getLanguageName(by: accountManager.languageToLearn)). Use basic and short sentences that are not complex, as if you were speaking to a 1 year old."),
            Message(role: "user", content: messages.last!.message.content)
        ]
        let dataModel = CompletionsRequest(model: selectedCompletionsModel, messages: messages, maxTokens: maxCompletionTokens, topP: 1)
        
        
        if (dataModel.messages.count == 0){
            return
        }
        
        // Identify System Message for use later
        let systemMessage = dataModel.messages.filter{ $0.role == "system" }.first
        
        // Put together list to save messages
        var conversationSoFar = dataModel
        
        // Keep completion request data, but update the message array to pass forward.
        conversationSoFar.messages = self.messages.compactMap { $0.message }
        
        // Add system prompt at the beginning of the conversation
        conversationSoFar.messages.insert(systemMessage ?? dataModel.messages[0], at: 0)
        
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
    
//    func sendMessageGetMessage(completionRequest: CompletionsRequest) async -> MessagingModel? {
//        
//        if (completionRequest.messages.count == 0){
//            return nil
//        }
//        
//        do {
//            let response = try await completionsService.fetchCompletion(completionRequest: completionRequest)
//            let responseMessage = response.choices?.first?.message ?? Message(role: "error", content: "error")
//            let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: true)
//            
//            return responseMessageModel
//            
//        } catch {
//            print("Error: \(error.localizedDescription)")
//        }
//        
//        return nil
//    }
    
    func sendMessageGetMessageString(completionRequest: CompletionsRequest) async -> String? {
        
        if (completionRequest.messages.count == 0){
            return nil
        }
        
        do {
            let response = try await completionsService.fetchCompletion(completionRequest: completionRequest)
            let responseMessage = response.choices?.first?.message ?? Message(role: "error", content: "error")
            //let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: true)
            
            return responseMessage.content
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func setTranslatedMessageAndAudio(messagingModel: MessagingModel) -> Bool {
        
        // Find the message to set the translation on
        if let index = messages.firstIndex(where: { $0.id == messagingModel.id }) {
            
            // Set translated message content here
            if (self.messages[index].translatedMessageContent == nil && messagingModel.translatedMessageContent != nil) {
                self.messages[index].translatedMessageContent = messagingModel.translatedMessageContent
            }
            
            // Set audio stuff here may have to change to translatedAudioData
            if (self.messages[index].audioData == nil && messagingModel.audioData != nil) {
                self.messages[index].audioData = messagingModel.audioData
            }
            
            // Set audio stuff here may have to change to translatedAudioData
            if (self.messages[index].translatedAudioData == nil && messagingModel.translatedAudioData != nil) {
                self.messages[index].translatedAudioData = messagingModel.translatedAudioData
            }
        }
        
        return true
    }
    
    func fetchAndPlayAudio(messagingModel: MessagingModel) async -> MessagingModel {
        
        isLoading = true
        errorMessage = nil
        
        var updatedMessagingModel = messagingModel
        
        do {
            let ttsRequest = TtsRequest(model: selectedTtsModel, input: messagingModel.message.content, voice: "echo", speed: 0.8)
            let audioData = try await ttsViewModel.fetchTts(ttsRequest: ttsRequest)
            ttsViewModel.playAudio(with: audioData)
            updatedMessagingModel.audioData = audioData
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        
        return updatedMessagingModel
    }
    
//    func fetchAndPlayAudioForMessagingModel(messagingModel: MessagingModel) async -> MessagingModel {
//        
//        isLoading = true
//        errorMessage = nil
//        
//        var updatedMessagingModel = messagingModel
//        
//        do {
//            let ttsRequest = TtsRequest(model: selectedTtsModel, input: messagingModel.message.content, voice: "echo", speed: 0.8)
//            let audioData = try await ttsViewModel.fetchTts(ttsRequest: ttsRequest)
//            ttsViewModel.playAudio(with: audioData)
//            updatedMessagingModel.audioData = audioData
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        
//        isLoading = false
//        
//        return updatedMessagingModel
//    }
    
//    func fetchAndPlayAudioReturnData(messagingModel: MessagingModel) async -> Data? {
//        
//        isLoading = true
//        errorMessage = nil
//                
//        do {
//            let ttsRequest = TtsRequest(model: selectedTtsModel, input: messagingModel.message.content, voice: "echo", speed: 0.8)
//            let audioData = try await ttsViewModel.fetchTts(ttsRequest: ttsRequest)
//            ttsViewModel.playAudio(with: audioData)
//            return audioData
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        
//        isLoading = false
//        
//        return nil
//    }
//    
    func fetchAndPlayAudioReturnData(messageToConvertAndPlay: String) async -> Data? {
        
        isLoading = true
        errorMessage = nil
                
        do {
            let ttsRequest = TtsRequest(model: selectedTtsModel, input: messageToConvertAndPlay, voice: "echo", speed: 0.8)
            let audioData = try await ttsViewModel.fetchTts(ttsRequest: ttsRequest)
            ttsViewModel.playAudio(with: audioData)
            return audioData
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        
        return nil
    }
    
//    func fetchAndPlayAudioForTranslatedMessage(messagingModel: MessagingModel) async -> MessagingModel {
//        
//        isLoading = true
//        errorMessage = nil
//        
//        var updatedMessagingModel = messagingModel
//        
//        do {
//            let ttsRequest = TtsRequest(model: selectedTtsModel, input: messagingModel.translatedMessageContent!, voice: "echo", speed: 0.8)
//            let audioData = try await ttsViewModel.fetchTts(ttsRequest: ttsRequest)
//            ttsViewModel.playAudio(with: audioData)
//            updatedMessagingModel.translatedAudioData = audioData
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        
//        isLoading = false
//        
//        return updatedMessagingModel
//    }
    
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
