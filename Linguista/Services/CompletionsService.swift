//
//  CompletionsService.swift
//  Linguista
//
//  Created by Daniel Grant on 10/9/24.
//

import Foundation
import Combine

class CompletionsService: ObservableObject {
    
    static let shared = CompletionsService()
    @Published var errorMessage: String?
    @Published var isLoading = false
    private let authService = AuthenticationService.shared
    private var cancellable: AnyCancellable?
    
//    func fetchCompletion(completionRequest: CompletionsRequest) -> CompletionsResponse {
//        
//        guard let url = URL(string: localBaseUrl + completionsEndpoint) else { return }
//        
//        authService.getAccessToken { [weak self] accessToken in
//            guard let self = self, let accessToken = accessToken else {
//                DispatchQueue.main.async {
//                    self?.errorMessage = "Failed to retrieve access token"
//                }
//                return
//            }
//            
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//            
//            do {
//                let jsonData = try JSONEncoder().encode(completionRequest)
//                request.httpBody = jsonData
//            } catch {
//                self.errorMessage = "Failed to encode requset: \(error.localizedDescription)"
//                return
//            }
//            
//            isLoading = true
//            errorMessage = nil
//            
//            let session = URLSession(configuration: .default, delegate: URLSessionPinningDelegate(), delegateQueue: nil)
//            
//            cancellable = session.dataTaskPublisher(for: request)
//                .map { $0.data }
//                .decode(type: CompletionsResponse.self, decoder: JSONDecoder())
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { completion in
//                    self.isLoading = false
//                    switch completion {
//                    case .finished:
//                        break
//                    case .failure(let error):
//                        self.errorMessage = error.localizedDescription
//                    }
//                }, receiveValue: { response in
//                    completion(.s)
//                    return response
//                    
//                    //let responseMessage = response.choices?.first?.message ?? Message(role: "error", content: "error")
//                    //let responseMessageModel = MessagingModel(message: responseMessage , isSentByUser: false)
//                    //self.messages.append(responseMessageModel)
//                })
//        }
//    }
//        deinit {
//            cancellable?.cancel()
//        }
    
    
    func fetchCompletion(completionRequest: CompletionsRequest) async throws -> CompletionsResponse {
        
        guard let url = URL(string: localBaseUrl + completionsEndpoint) else {
            throw URLError(.badURL)
        }
        
        let accessToken = try await authService.getAccessToken()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let jsonData = try JSONEncoder().encode(completionRequest)
        request.httpBody = jsonData
        
        isLoading = true
        errorMessage = nil
        
        let session = URLSession(configuration: .default, delegate: URLSessionPinningDelegate(), delegateQueue: nil)
        
        let (data, _) = try await session.data(for: request)
        
        let response = try JSONDecoder().decode(CompletionsResponse.self, from: data)
        
        isLoading = false
        return response
    }
}
