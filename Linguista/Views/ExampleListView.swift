//
//  ExampleListView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import Foundation
import SwiftUI

struct ExampleListView: View {
    @StateObject private var viewModel = ListViewModel()
    let items: [String]

    var body: some View {
        List(items, id: \.self) { item in
            Text(item)
                .padding()
                .background(viewModel.selectedItem == item ? Color.blue : Color.clear)
                .foregroundColor(viewModel.selectedItem == item ? .white : .black)
                .cornerRadius(8)
                .onTapGesture {
                    viewModel.selectedItem = item
                    performAction(for: item)
                }
        }
        .navigationTitle("Predefined Items")
    }

    private func performAction(for item: String) {
        // Perform any action based on the selected item
        print("Selected item: \(item)")
        
        
    }
}

struct ExampleListView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleListView(items: predefinedPrompts)
    }
}
