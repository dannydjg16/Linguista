//
//  AuthenticationService.swift
//  Linguista
//
//  Created by Daniel Grant on 8/6/24.
//

import Foundation

class AuthenticationService {
    
    static let shared = AuthenticationService()
    private var accessToken: String?
    private let tokenURL = authBaseUrl + authTokenEndpoint
    private let clientID = Config.shared.value(forKey: "ClientID")!
    private let clientSecret = Config.shared.value(forKey: "ClientSecret")!
    
    private init() {}
    
    func getAccessToken() async throws -> String {
        
        if let accessToken = accessToken {
            return accessToken
        }
        
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("DT=DI1brEE1KCETA2iL_xaCaA__Q; JSESSIONID=5EB2F46E2DD792B57D77ADB3FD2A32E5; t=default", forHTTPHeaderField: "Cookie")
        
        let requestBody = "grant_type=client_credentials&scope=AccessAll&client_id=\(clientID)&client_secret=\(clientSecret)"
        request.httpBody = requestBody.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
            
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let accessToken = json["access_token"] as? String {
                self.accessToken = accessToken
                return accessToken
            } else {
                throw URLError(.badServerResponse)
            }
        } else {
            throw URLError(.badServerResponse)
        }
    }
}
