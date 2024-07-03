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
        
        VStack {
            List(popularLanguages, id: \.self) { language in
                NavigationLink(destination: MessageView(selectedLanguage: language)) {
                    Text(language)
                }
            }
            .listStyle(PlainListStyle()) // Optional: Use plain list style to reduce extra padding
        }
        .navigationTitle("Select a Language")
        .navigationViewStyle(StackNavigationViewStyle()) // Ensure proper navigation view style
    }
}

struct LanguageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSelectionView()
    }
}
