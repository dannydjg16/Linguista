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
    @Published var isSignedIn: Bool = false
    
    private var isSignedIn: Bool {
        !userID.isEmpty
    }
    
    @Published var userID: String = ""
    @Published var username: String = ""
    @Published var languageToLearn: Int = 1
    @Published var name: String = ""
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        if let storedUserID = KeychainManager.load(key: "appleUserID") {
            userID = storedUserID
            isSignedIn = true
            // Optionally load userName from backend or local storage
        }
        
        self.context = context
        loadFromCoreData()
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
}
