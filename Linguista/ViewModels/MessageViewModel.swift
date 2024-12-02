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
    private let completionsService = CompletionsService.shared
    
    func fetchCompletion(completionRequest: CompletionsRequest) async {
        do {
            let response = try await completionsService.fetchCompletion(completionRequest: completionRequest)
            DispatchQueue.main.async {
                self.completionResponse = response
            }
        } catch {
            // Do Error Handling
        }
    }
    
}
