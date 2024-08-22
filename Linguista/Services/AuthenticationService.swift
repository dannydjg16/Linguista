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
    
    private init() {}
    
    private var accessToken: String?
    
    private let tokenURL = "https://dev-7824301.okta.com/oauth2/default/v1/token"
    
    private let clientID = Config.shared.value(forKey: "ClientID")!
    private let clientSecret = Config.shared.value(forKey: "ClientSecret")!
    
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
        
        //let requestBody = "grant_type=client_credentials&scope=AccessAll&client_id=\(clientID)&client_secret=\(clientSecret)"
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
    
    func getAccessTokenA() async throws -> String {
        // Check if the access token is already available
        if let accessToken = self.accessToken {
            return accessToken
        }

        guard let url = URL(string: tokenURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("DT=DI1brEE1KCETA2iL_xaCaA__Q; JSESSIONID=5EB2F46E2DD792B57D77ADB3FD2A32E5; t=default", forHTTPHeaderField: "Cookie")
        
        let requestBody = "grant_type=client_credentials&scope=AccessAll&client_id=\(clientID)&client_secret=\(clientSecret)"
        request.httpBody = requestBody.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let accessToken = json["access_token"] as? String {
                self.accessToken = accessToken
                return accessToken
            } else {
                throw URLError(.cannotParseResponse)
            }
        } catch {
            throw error
        }
    }
    
    func clearAccessToken() {
        accessToken = nil
    }
}
