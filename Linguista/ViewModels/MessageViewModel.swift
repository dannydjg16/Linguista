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
        guard let url = URL(string: "https://localhost:7244/OpenAi/completions") else { return }
        
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
    
    func sendRequest(completionsRequest: CompletionsRequest) {
        guard let url = URL(string: "https://localhost:7244/OpenAi/completions") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(completionsRequest)
            request.httpBody = jsonData
        } catch {
            print("Error encoding data: \(error)")
            return
        }

        let session = URLSession(configuration: .default, delegate: CustomSessionDelegate(), delegateQueue: nil)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }

        task.resume()
    }

