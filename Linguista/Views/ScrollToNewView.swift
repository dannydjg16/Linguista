//
//  ScrollToNewView.swift
//  Linguista
//
//  Created by Daniel Grant on 9/16/24.
//

import SwiftUI

struct ScrollToNewView: View {
    
    @State private var languageToTranslate: String = ""
    @State private var customLanguage: String = ""
    @State private var showCustomLanguageField: Bool = false
    
    var body: some View {
        VStack {
            Picker("Language: ", selection: $languageToTranslate) {
                ForEach(popularLanguageObjects) { language in
                    Text(language.name).tag(language.id)
                }
                // Add an "Other" option
                Text("Other").tag("Other")
            }
            .pickerStyle(NavigationLinkPickerStyle())
            .padding([.leading, .trailing], 16)
            .padding([.top, .bottom], 10)
            .onChange(of: languageToTranslate) {
                showCustomLanguageField = (languageToTranslate == "Other")
            }
        }
        
        // Show a TextField for custom language when "Other" is selected
        if showCustomLanguageField {
            TextField("Enter custom language", text: $customLanguage)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}


struct ScrollToNewView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollToNewView()
    }
}
