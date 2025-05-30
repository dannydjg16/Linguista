//
//  AccountView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import SwiftUI
import AuthenticationServices

struct AccountView: View {
    
    @AppStorage("appleUserID") private var appleUserID: String = ""
    @State private var userName: String = ""

    var body: some View {
        
        VStack(spacing: 20) {
            
            if isSignedIn {
                Text("Welcome, \(userName.isEmpty ? "User" : userName)!")
                    .font(.title)
                
                Button(action: {
                    signOut()
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200, height: 45)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            
            else {
                Spacer()
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
                .signInWithAppleButtonStyle(.whiteOutline)
                .frame(width: 200, height: 45)
                .padding()
            }
        }
        .onAppear {
            // Optional: Validate user ID on view appearance
            if !appleUserID.isEmpty {
                print("User is signed in: \(appleUserID)")
            } else {
                print("User is NOT  signed in!!!!!!!!")
            }
        }
    }
    
    private var isSignedIn: Bool {
        !appleUserID.isEmpty
    }
    
    private func signOut() {
        appleUserID = "" // Clear stored user ID
        userName = "" // Clear user name
        print("User signed out")
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
            
            appleUserID = appleIDCredential.user
            if let fullName = appleIDCredential.fullName {
                userName = [fullName.givenName, fullName.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
