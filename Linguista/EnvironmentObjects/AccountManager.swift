//
//  AccountManager.swift
//  Linguista
//
//  Created by Daniel Grant on 5/16/25.
//

import Foundation
import Combine
import CoreData

class AccountManager: ObservableObject {
    
    @Published var userID: String = ""
    @Published var username: String = ""
    @Published var languageToLearn: Int = 1
    @Published var name: String = ""
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadFromCoreData()
    }
    
    func isSignedIn() -> Bool {
        !userID.isEmpty
    }
    
    func loadFromCoreData() {
        let request: NSFetchRequest<AccountModel> = AccountModel.fetchRequest()
        do {
            let accounts = try context.fetch(request)
            if let account = accounts.first {
                languageToLearn = Int(account.languagePreference)
                username = account.username ?? ""
            }
        } catch {
            print("Error loading from Core Data: \(error)")
        }
    }
    
    func saveToCoreData() {
        let request: NSFetchRequest<AccountModel> = AccountModel.fetchRequest()
        do {
            let accounts = try context.fetch(request)
            let account: AccountModel
            if let existingAccount = accounts.first {
                account = existingAccount
            } else {
                account = AccountModel(context: context)
            }
            account.username = username
            account.languagePreference = Int16(languageToLearn)
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
    
    func signOut() {
        userID = "" // Clear stored user ID
        username = "" // Clear user name
        print("User signed out")
    }
}
