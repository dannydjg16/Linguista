//
//  PromptView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import Foundation
import SwiftUI

struct PromptView: View {
    let items: [String] // Replace with your model data
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        PromptView(items: Array(1...20).map { "Item \($0)" })
    }
}
