//
//  ProfileView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/16/26.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    // Using @State so the view updates when user signs out
    @State private var user: User? = UserManager.shared.currentUser
    
    var body: some View {
        VStack(spacing: 20) {
            if let user = user {
                // User is signed in - show their info
                Text("Welcome to Linguista, \(user.name)")
                    .font(.title)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button("Sign Out") {
                    signOut()
                }
                .foregroundColor(.red)
                
            } else {
                // User is signed out - show nothing personal
                
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    handleSignIn(result)
                }
                .frame(height: 50)
                
                Text("Sign in for more features")
                    .font(.callout)
            }
        }
        .padding()
    }
    
    func signOut() {
        UserManager.shared.clearUser()
        // This clears the view by setting local state to nil
        // The data is removed from UserDefaults but this is
        // what actually updates the UI
        user = nil
    }
    
    func handleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userId = credential.user
                let name = [
                    credential.fullName?.givenName,
                    credential.fullName?.familyName
                ]
                .compactMap { $0 }
                .joined(separator: " ")
                
                let email = credential.email ?? "No email provided"
                
                let newUser = User(
                    userId: userId,
                    name: name.isEmpty ? "" : name,
                    email: email
                )
                
                UserManager.shared.currentUser = newUser
                // Update the view state
                user = newUser
            }
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
}
