//
//  AccountView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import SwiftUI
import AuthenticationServices

struct AccountView: View {
    
    @EnvironmentObject var accountManager: AccountManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        
        VStack(spacing: 20) {
            
            AccountSettingsView()
                        
            if accountManager.isSignedIn() {
                
                // Would be cool to replace welcome with the language they are learning greeting.
                Text("Welcome, \($accountManager.name)!")
                    .font(.title)
                
                Divider()
                    .frame(height: 1)
                    .background(colorScheme == .light ? Color.black.opacity(0.3) : Color.white)
                    .padding(.leading)
                    .padding(.trailing)
                
                HStack {
                    Text("Language to Learn:")
                        .padding(.leading)
                        .foregroundColor(colorScheme == .light ? Color(red: 0.3, green: 0.15, blue: 0.05) : Color.white)
                    Spacer()
                }
                
                LanguagePickerView()
                
                Spacer()
                
                Spacer()
                
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
            if !accountManager.userID.isEmpty {
                print("User is signed in: \(accountManager.userID)")
            } else {
                print("User is NOT  signed in!!!!!!!!")
            }
        }
    }
    
    func handleAuthorization(_ authorization: ASAuthorization) {
        print("Authorization object: \(authorization)")
        print("Credential: \(authorization.credential)")
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            // Save user credentials or send to your server for verification
            print("User ID: \(userID)")
            print("Email: \(email ?? "No email")")
            print("Full Name: \(fullName?.givenName ?? "No name")")
            
            accountManager.userID = appleIDCredential.user
            accountManager.name = "Daniel"
            if let fullName = appleIDCredential.fullName {
                accountManager.name = [fullName.givenName, fullName.familyName]
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
