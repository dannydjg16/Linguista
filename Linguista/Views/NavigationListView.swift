//
//  NavigationListView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/27/24.
//

import Foundation
import SwiftUI

struct NavigationListView: View {
    
    var body: some View {
        NavigationView {
            List(predefinedPrompts, id: \.self) { item in
                NavigationLink(destination: self.destinationView(for: item)) {
                                    Text(item)
                                }
            }
            .navigationTitle("LANGUAGE HERE")
        }
    }
    
    @ViewBuilder
        private func destinationView(for item: String) -> some View {
            if item == predefinedPrompts[0] {
                DetailView(item: item)
            } else if item == "Item 2" {
                LearnView()
            } else {
                LearnView()
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

struct NavigationListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationListView()
    }
}
