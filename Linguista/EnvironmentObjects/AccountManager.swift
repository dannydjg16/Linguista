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
    @Published var userPreferredLanguage: String = ""
    
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

//struct ContentView: View {
//    @EnvironmentObject var userManager: UserManager
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            if userManager.isSignedIn {
//                Text("Welcome, \(userManager.userName.isEmpty ? "User" : userManager.userName)!")
//                    .font(.title)
//                Button(action: { userManager.signOut() }) {
//                    Text("Sign Out")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(width: 200, height: 45)
//                        .background(Color.red)
//                        .cornerRadius(10)
//                }
//            } else {
//                SignInWithAppleButton(
//                    .signIn,
//                    onRequest: { request in
//                        request.requestedScopes = [.fullName, .email]
//                    },
//                    onCompletion: { result in
//                        switch result {
//                        case .success(let authResults):
//                            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
//                                let userName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
//                                    .compactMap { $0 }
//                                    .joined(separator: " ")
//                                userManager.signIn(userID: appleIDCredential.user, userName: userName)
//                            }
//                        case .failure(let error):
//                            print("Sign-in failed: \(error.localizedDescription)")
//                        }
//                    }
//                )
//                .signInWithAppleButtonStyle(.black)
//                .frame(width: 200, height: 45)
//            }
//        }
//    }
//}
