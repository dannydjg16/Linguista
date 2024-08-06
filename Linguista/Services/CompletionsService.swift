//
//  CompletionsService.swift
//  Linguista
//
//  Created by Daniel Grant on 6/27/24.
//
import SwiftUI
import Combine
import Foundation

//class CompletionService {
//    func sendRequest(completionRequest: CompletionsRequest) -> AnyPublisher<CompletionsResponse, Error> {
//        let url = URL(string: "http://localhost:7244/openai/completions")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let encoder = JSONEncoder()
//        do {
//            request.httpBody = try encoder.encode(completionRequest)
//        } catch {
//            return Fail(error: error).eraseToAnyPublisher()
//        }
//        
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .mapError { $0 as Error }
//            .map { $0.data }
//            .decode(type: CompletionsResponse.self, decoder: JSONDecoder())
//            .eraseToAnyPublisher()
//    }
//}

class CompletionService {
    private let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        let delegate = CustomSessionDelegate()
        session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
    
    func sendRequest(completionRequest: CompletionsRequest) -> AnyPublisher<CompletionsResponse, Error> {
        let url = URL(string: "https://linguista-appservice.azurewebsites.net/openai/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            request.httpBody = try encoder.encode(completionRequest)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .mapError { $0 as Error }
            .map { $0.data }
            .decode(type: CompletionsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
