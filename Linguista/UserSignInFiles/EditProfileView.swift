//
//  EditProfileView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/19/26.
//


import SwiftUI

struct EditProfileView: View {
    @State private var name: String
    @State private var email: String
    @Environment(\.dismiss) var dismiss
    
    init() {
        // Initialize with current user data
        let currentUser = UserManager.shared.currentUser
        _name = State(initialValue: currentUser?.name ?? "")
        _email = State(initialValue: currentUser?.email ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button("Save Changes") {
                        saveProfile()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
    
    func saveProfile() {
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        // Create updated user with new info
        let updatedUser = AppUser(
            userId: currentUser.userId,
            name: name,
            email: email
        )
        
        UserManager.shared.currentUser = updatedUser
        dismiss()
    }
}