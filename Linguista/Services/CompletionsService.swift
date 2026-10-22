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
    
    func fetchImage(imageRequest: ImageRequest) async throws -> Data {
        
        guard let url = URL(string: apiBaseUrl + imageEndpoint) else {
            throw URLError(.badURL)
        }
        
        let accessToken = try await authService.getAccessToken()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // Image generation regularly takes longer than the default 60 second timeout
        request.timeoutInterval = 180
        
        let jsonData = try JSONEncoder().encode(imageRequest)
        request.httpBody = jsonData
        
        let session = URLSession(configuration: .default, delegate: URLSessionPinningDelegate(), delegateQueue: nil)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // The API can either pass the image bytes straight through or return OpenAI's JSON payload
        if httpResponse.mimeType?.hasPrefix("image/") == true {
            return data
        }
        
        let imageResponse = try JSONDecoder().decode(ImageResponse.self, from: data)
        
        if let base64 = imageResponse.data.first?.b64Json, let imageData = Data(base64Encoded: base64) {
            return imageData
        }
        
        if let urlString = imageResponse.data.first?.url, let imageUrl = URL(string: urlString) {
            let (imageData, _) = try await URLSession.shared.data(from: imageUrl)
            return imageData
        }
        
        throw URLError(.cannotDecodeContentData)
    }
}

class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
}
