//
//  AccountService.swift
//  Linguista
//
//  Created by Daniel Grant on 6/1/25.
//

import Foundation

class AccountService: ObservableObject {
    
    static let shared = CompletionsService()
    @Published var errorMessage: String?
    @Published var isLoading = false
    private let authService = AuthenticationService.shared
    
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
