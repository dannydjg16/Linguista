//
//  AuthenticationService.swift
//  Linguista
//
//  Created by Daniel Grant on 8/6/24.
//

import Foundation

import Foundation

class AuthenticationService {
    
    static let shared = AuthenticationService()
    private var accessToken: String?
    private let tokenURL = authBaseUrl + authTokenEndpoint
    private let clientID = Config.shared.value(forKey: "ClientID")!
    private let clientSecret = Config.shared.value(forKey: "ClientSecret")!
    
    private init() {}
    
    func getAccessToken(completion: @escaping (String?) -> Void) {
        
        guard accessToken == nil else {
            completion(accessToken)
            return
        }
        
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("DT=DI1brEE1KCETA2iL_xaCaA__Q; JSESSIONID=5EB2F46E2DD792B57D77ADB3FD2A32E5; t=default", forHTTPHeaderField: "Cookie")
        
        let requestBody = "grant_type=client_credentials&scope=AccessAll&client_id=\(clientID)&client_secret=\(clientSecret)"

        request.httpBody = requestBody.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = json["access_token"] as? String {
                    self.accessToken = accessToken
                    completion(accessToken)
                } else {
                    print("Error: Unable to parse access token from response")
                    completion(nil)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func clearAccessToken() {
        accessToken = nil
    }
    
    func getAccessToken() async throws -> String {
        
        // If the token is already available, return it
        if let accessToken = accessToken {
            return accessToken
        }
        
        // Prepare the URLRequest
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("DT=DI1brEE1KCETA2iL_xaCaA__Q; JSESSIONID=5EB2F46E2DD792B57D77ADB3FD2A32E5; t=default", forHTTPHeaderField: "Cookie")
        
        let requestBody = "grant_type=client_credentials&scope=AccessAll&client_id=\(clientID)&client_secret=\(clientSecret)"
        request.httpBody = requestBody.data(using: .utf8)
        
        // Perform the request using async/await
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for a valid response (status code in 200 range)
        if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
            
            // Parse the JSON response to extract the access token
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let accessToken = json["access_token"] as? String {
                self.accessToken = accessToken
                return accessToken
            } else {
                throw URLError(.badServerResponse) // Error: Unable to parse access token from response
            }
        } else {
            throw URLError(.badServerResponse) // Error: Invalid response
        }
    }
}
