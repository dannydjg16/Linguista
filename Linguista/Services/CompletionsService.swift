//
//  CompletionsService.swift
//  Linguista
//
//  Created by Daniel Grant on 6/27/24.
//
import SwiftUI
import Combine
import Foundation

// Service class to handle networking
class CompletionService {
    func sendRequest(completionRequest: CompletionsRequest) -> AnyPublisher<Data, Error> {
        let url = URL(string: "https://localhost:7244/openai/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            request.httpBody = try encoder.encode(completionRequest)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { $0 as Error }
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}
