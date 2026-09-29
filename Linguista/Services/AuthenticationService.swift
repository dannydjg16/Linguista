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
    private var tokenExpiry: Date?
    private let tokenURL = authBaseUrl + authTokenEndpoint
    private let clientID = Config.shared.value(forKey: "ClientID")!
    private let clientSecret = Config.shared.value(forKey: "ClientSecret")!
    private let audience = Config.shared.value(forKey: "Audience")!

    private init() {}

    func getAccessToken() async throws -> String {

        if let accessToken = accessToken, let tokenExpiry = tokenExpiry, tokenExpiry > Date() {
            return accessToken
        }

        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "client_credentials"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "audience", value: audience)
        ]
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
              let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let accessToken = json["access_token"] as? String else {
            throw URLError(.badServerResponse)
        }

        // Refresh a minute early so a request never goes out with a just-expired token
        let expiresIn = json["expires_in"] as? Double ?? 3600
        self.accessToken = accessToken
        self.tokenExpiry = Date().addingTimeInterval(expiresIn - 60)
        return accessToken
    }
}
