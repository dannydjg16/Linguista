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
                                    Text(item)
                                }
            }
            .navigationTitle("\(selectedLanguage)")
    }
    
    @ViewBuilder
        private func destinationView(for item: String) -> some View {
            if item == predefinedPrompts[0] {
                DetailView(item: item)
            } else if item == "Item 2" {
                DetailView(item: item)
            } else {
                DetailView(item: item)
            }
        }
}

struct DetailView: View {
    var item: String
    
    var body: some View {
        VStack {
            Text("Selected: \(item)")
                .font(.largeTitle)
        }
        .navigationTitle(item)
    }
}

struct SelectPromptView_Previews: PreviewProvider {
    static var previews: some View {
        SelectPromptView(selectedLanguage: "Farsi")
    }
}
