//
//  CompletionsService.swift
//  Linguista
//
//  Created by Daniel Grant on 10/9/24.
//

import Foundation

class CompletionsService: ObservableObject {
    
    static let shared = CompletionsService()
    @Published var errorMessage: String?
    @Published var isLoading = false
    private let authService = AuthenticationService.shared
    
    func fetchCompletion(completionRequest: CompletionsRequest) async throws -> CompletionsResponse {
        
        guard let url = URL(string: apiBaseUrl + completionsEndpoint) else {
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
    
    func fetchTts(ttsRequest: TtsRequest) async throws -> Data {

        guard let url = URL(string: apiBaseUrl + ttsEndpoint) else {
            throw URLError(.badURL)
        }
        
        let accessToken = try await authService.getAccessToken()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let jsonData = try JSONEncoder().encode(ttsRequest)
        request.httpBody = jsonData
        
        isLoading = true
        errorMessage = nil
        
        let session = URLSession(configuration: .default, delegate: URLSessionPinningDelegate(), delegateQueue: nil)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        isLoading = false
        return data
    }
}

class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Disable SSL certificate validation for local development
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
}
