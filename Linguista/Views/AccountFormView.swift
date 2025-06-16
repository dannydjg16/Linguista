//
//  AccountFormView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/11/25.
//


import SwiftUI

struct AccountFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                    SecureField("Password", text: $password)
                }

                Button(action: saveAccount) {
                    Text("Save Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Add Account")
        }
    }

    private func saveAccount() {
        withAnimation {
            let newAccount = AccountModel(context: viewContext)
            newAccount.username = username
            newAccount.email = email
            newAccount.password = password
            newAccount.createdAt = Date()

            do {
                try viewContext.save()
                // Clear form fields after saving
                username = ""
                email = ""
                password = ""
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
