//
//  LanguagePickerView.swift
//  Linguista
//
//  Created by Daniel Grant on 1/15/25.
//

import Foundation
import SwiftUI
import CoreData

struct LanguagePickerView: View {
    
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        entity: Account.entity(),
//        sortDescriptors: [],
//        predicate: NSPredicate(format: "TRUEPREDICATE"),
//        animation: .default
//    ) private var accounts: FetchedResults<Account>
//    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.createdAt, ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<Account>


    @State private var selectedLanguage: Int16 = 2
    
    var body: some View {
        Picker("Language: ", selection: $selectedLanguage) {
            ForEach(popularLanguageObjects) { language in
                Text(language.name).tag(language.id)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 200)
        .padding()
        .background(Color.brown.opacity(0.15))
        .tint(.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.brown.opacity(0.15), lineWidth: 2)
        )
        .onChange(of: selectedLanguage) {
            saveLanguage(selectedLanguage)
        }
        .onAppear {
            loadSavedLanguage()
        }
    }
    
    private func loadSavedLanguage() {
        if let account = accounts.first {
            selectedLanguage = Int16(account.languagePreference)
        } else {
            selectedLanguage = 2
        }
    }
    
    private func saveLanguage(_ language: Int16) {
        withAnimation {
            let account: Account
            if let existingAccount = accounts.first {
                account = existingAccount
            } else {
                account = Account(context: viewContext)
            }
            account.languagePreference = Int16(language)
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving age: \(error)")
            }
        }
    }
}
