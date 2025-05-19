//
//  AccountManager.swift
//  Linguista
//
//  Created by Daniel Grant on 5/16/25.
//

import Foundation
import Combine

class AccountManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var userID: String = ""
    @Published var userName: String = ""
    @Published var userPreferredLanguage: Int = 0
    
    init() {
        if let storedUserID = KeychainManager.load(key: "appleUserID") {
            userID = storedUserID
            isSignedIn = true
            // Optionally load userName from backend or local storage
        }
    }
    
    func signIn(userID: String, userName: String) {
        KeychainManager.save(key: "appleUserID", data: userID)
        self.userID = userID
        self.userName = userName
        isSignedIn = true
    }
    
    func signOut() {
        KeychainManager.delete(key: "appleUserID")
        userID = ""
        userName = ""
        isSignedIn = false
    }
}
