//
//  AuthViewController.swift
//  Linguista
//
//  Created by Daniel Grant on 2/16/26.
//


import AuthenticationServices
import Foundation

class AuthViewController: UIViewController, ASAuthorizationControllerDelegate {
    
    func handleSignInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    // Called when sign in succeeds
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = credential.user
            
            // Apple only provides name/email on FIRST sign in
            // so we check if we already have the user saved
            if let existingUser = UserManager.shared.currentUser {
                // User already exists, just confirm still logged in
                print("Welcome back, \(existingUser.name)")
            } else {
                // First time sign in - save their info
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
                print("Welcome, \(newUser.name)")
            }
            
            // Navigate to home screen
            navigateToHome()
        }
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("Sign in failed: \(error.localizedDescription)")
    }
    
    func navigateToHome() {
        // Your navigation logic here
    }
}
