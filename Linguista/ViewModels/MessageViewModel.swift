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

    func sendMessage(completionRequest: CompletionsRequest) {
        completionService.sendRequest(completionRequest: completionRequest)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { response in
                self.completionResponse = response
            })
            .store(in: &cancellables)
    }
}
