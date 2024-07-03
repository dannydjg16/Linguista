//
//  LanguageSelectionView.swift
//  Linguista
//
//  Created by Daniel Grant on 7/2/24.
//

import Foundation
import SwiftUI

struct LanguageSelectionView: View {

    var body: some View {
        NavigationView {
            List(popularLanguages, id: \.self) { language in
                NavigationLink(destination: MessageView(selectedLanguage: language)) {
                    Text(language)
                }
            }
            .navigationTitle("Which Language Would You Like To Learn?")
        }
    }
    
}
