//
//  LanguagePickerView.swift
//  Linguista
//
//  Created by Daniel Grant on 1/15/25.
//

import Foundation
import SwiftUI

struct LanguagePickerView: View {
    @Binding var languageToTranslate: Int

    var body: some View {
        Picker("Language: ", selection: $languageToTranslate) {
            ForEach(popularLanguageObjects) { language in
                Text(language.name).tag(language.id)
            }
        }
        .pickerStyle(NavigationLinkPickerStyle())
        .padding()
        .background(Color.brown.opacity(0.15))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.brown.opacity(0.15), lineWidth: 2)
        )
    }
}
