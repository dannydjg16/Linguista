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
    @Published var isLoading = false
    private var cancellable: AnyCancellable?
    private let completionService = CompletionService()
    
    func fetchCompletion(completionRequest: CompletionsRequest) {
        guard let url = URL(string: "https://linguista-appservice.azurewebsites.net/openai/completions") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(completionRequest)
            request.httpBody = jsonData
        } catch {
            self.errorMessage = "Failed to encode requset: \(error.localizedDescription)"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let session = URLSession(configuration: .default, delegate: URLSessionPinningDelegate(), delegateQueue: nil)
        
        cancellable = session.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: CompletionsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { response in
                self.completionResponse = response
            })
    }
    
    deinit {
        cancellable?.cancel()
    }
}

class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Disable SSL certificate validation for local development
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
}
