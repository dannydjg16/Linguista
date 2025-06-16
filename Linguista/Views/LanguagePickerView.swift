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
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AccountModel.createdAt, ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<AccountModel>

    @State private var selectedLanguage: Int = 1
    
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
            selectedLanguage = Int(account.languagePreference)
        } else {
            selectedLanguage = 2
        }
    }
    
    private func saveLanguage(_ language: Int) {
        withAnimation {
            let account: AccountModel
            if let existingAccount = accounts.first {
                account = existingAccount
            } else {
                account = AccountModel(context: viewContext)
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
