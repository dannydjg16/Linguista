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
    @State private var user: User? = UserManager.shared.currentUser
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = user {
                    // User is signed in - show their info
                    Text("Welcome, \(user.name)")
                        .font(.title)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button("Edit Profile") {
                        showEditProfile = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Sign Out") {
                        signOut()
                    }
                    .foregroundColor(.red)
                    
                } else {
                    // User is signed out
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleSignIn(result)
                    }
                    .frame(height: 50)
                    
                    Text("Please sign in")
                        .font(.title)
                }
            }
            .padding()
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .onAppear {
                // Refresh user data when view appears (in case it was edited)
                user = UserManager.shared.currentUser
            }
        }
    }
    
    func signOut() {
        UserManager.shared.clearUser()
        user = nil
    }
    
    func handleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userId = credential.user
                
                // Check if user already exists
                if let existingUser = UserManager.shared.currentUser {
                    user = existingUser
                } else {
                    // First time sign in
                    let name = [
                        credential.fullName?.givenName,
                        credential.fullName?.familyName
                    ]
                    .compactMap { $0 }
                    .joined(separator: " ")
                    
                    let email = credential.email ?? "No email provided"
                    
                    let newUser = User(
                        userId: userId,
                        name: name.isEmpty ? "Apple User" : name,
                        email: email
                    )
                    
                    UserManager.shared.currentUser = newUser
                    user = newUser
                }
            }
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
}
