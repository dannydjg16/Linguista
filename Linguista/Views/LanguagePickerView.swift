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
    
    @EnvironmentObject var accountManager: AccountManager
    
    var body: some View {
        Picker("Language: ", selection: $accountManager.languageToLearn) {
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
        .onChange(of: accountManager.languageToLearn) {
            accountManager.saveToCoreData()
        }
    }
}
