//
//  MessagingViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 8/20/24.
//

import Foundation

import Combine

class MessagingViewModel: ObservableObject {
    @Published var messages: [MessagingModel] = []
    private let authService = AuthenticationService.shared
    private var cancellable: AnyCancellable?
    @Published var completionResponse: CompletionsResponse?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func sendMessage(completionRequest: CompletionsRequest)  {
        // Add the user's message to the list
        let userMessage = MessagingModel(message: completionRequest.messages.first!, isSentByUser: true)
        messages.append(userMessage)
        
    
    }
}


