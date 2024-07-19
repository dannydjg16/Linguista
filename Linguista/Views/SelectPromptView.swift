//
//  SelectPromptView.swift
//  Linguista
//
//  Created by Daniel Grant on 7/3/24.
//

import Foundation
//
//  NavigationListView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/27/24.
//

import Foundation
import SwiftUI

struct SelectPromptView: View {
    let selectedLanguage: String
    
    var body: some View {
        List(predefinedPrompts, id: \.self) { item in
            NavigationLink(destination: self.destinationView(for: item)) {
                Text("\(item) \(selectedLanguage)")
            }
        }
        .navigationTitle("\(selectedLanguage)")
    }
    
    @ViewBuilder
    private func destinationView(for item: String) -> some View {
        if item == predefinedPrompts[0] {
            MessageView(selectedLanguage: selectedLanguage, selectedPrompt: item)
        } else if item == predefinedPrompts[1] {
            MessageView(selectedLanguage: selectedLanguage, selectedPrompt: item)
        }
        else if item == predefinedPrompts[2] {
            MessageView(selectedLanguage: selectedLanguage, selectedPrompt: item)
        }
        else if item == predefinedPrompts[3] {
            MessageView(selectedLanguage: selectedLanguage, selectedPrompt: item)
        }
        else if item == predefinedPrompts[4] {
            MessageView(selectedLanguage: selectedLanguage, selectedPrompt: item)
        }
    }
}

struct SelectPromptView_Previews: PreviewProvider {
    static var previews: some View {
        SelectPromptView(selectedLanguage: "Farsi")
    }
}
