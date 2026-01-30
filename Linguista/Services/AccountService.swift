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

}
