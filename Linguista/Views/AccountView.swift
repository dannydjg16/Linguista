//
//  AccountView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import SwiftUI
import AuthenticationServices

struct AccountView: View {
    
    //@Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack{
            Spacer()
            SignInWithAppleButton(
                .signIn, // Button type: .signIn or .continue
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        print("Authorization successful: \(authResults)")
                        // Handle successful sign-in (e.g., extract user ID, token, etc.)
                        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                            let userID = appleIDCredential.user
                            let fullName = appleIDCredential.fullName
                            let email = appleIDCredential.email
                            print("User ID: \(userID)")
                            print("Full Name: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
                            print("Email: \(email ?? "")")
                        }
                    case .failure(let error):
                        print("Authorization failed: \(error.localizedDescription)")
                    }
                }
            )
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(width: 200, height: 45)
            .padding()
        }
        

        
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

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
