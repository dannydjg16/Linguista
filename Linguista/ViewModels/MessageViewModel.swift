//
//  MessageViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 7/9/24.
//

import Foundation
import Combine
import SwiftUI

class MessageViewModel: ObservableObject {
    @Published var completionResponse: CompletionsResponse?
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    private let completionService = CompletionService()

    func sendRequest() {
        let message1 = Message(role: "system", content: "System message")
        let message2 = Message(role: "user", content: "User message")
        
        let completionRequest = CompletionsRequest(
            model: "gpt-3.5-turbo",
            messages: [message1, message2],
            temperature: 0.2,
            maxTokens: 20,
            topP: 1
        )
        
        completionService.sendRequest(completionRequest: completionRequest)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { response in
                self.completionResponse = response
            })
            .store(in: &cancellables)
    }
}
