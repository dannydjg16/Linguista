//
//  NavigationListView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/27/24.
//

import Foundation
import SwiftUI

struct NavigationListView: View {
    let items = ["Item 1", "Item 2", "Item 3"] // Example data
    
    var body: some View {
        NavigationView {
            List(items, id: \.self) { item in
                NavigationLink(destination: DetailView(item: item)) {
                    Text(item)
                }
            }
            .navigationTitle("Items")
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
