//
//  UserManager.swift
//  Linguista
//
//  Created by Daniel Grant on 2/16/26.
//
import Foundation
class UserManager {
    static let shared = UserManager()
    private let userKey = "currentUser"
    
    var currentUser: User? {
        get { getUser() }
        set {
            if let user = newValue {
                saveUser(user)
            } else {
                clearUser()
            }
        }
    }
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    private func getUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    func clearUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
}
