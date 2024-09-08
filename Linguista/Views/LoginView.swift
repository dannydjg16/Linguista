//
//  LoginView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    var body: some View {
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    // Configure your request here
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        handleAuthorization(authorization)
                    case .failure(let error):
                        print("Sign in with Apple failed: \(error.localizedDescription)")
                    }
                }
            )
            .signInWithAppleButtonStyle(.black) // You can change to .white or .whiteOutline
            .frame(width: 280, height: 60)
        }
        
        func handleAuthorization(_ authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userID = appleIDCredential.user
                let email = appleIDCredential.email
                let fullName = appleIDCredential.fullName
                // Save user credentials or send to your server for verification
                print("User ID: \(userID)")
                print("Email: \(email ?? "No email")")
                print("Full Name: \(fullName?.givenName ?? "No name")")
            }
        }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
