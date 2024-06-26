//
//  CollectionExampleView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import Foundation
import SwiftUI

struct CollectionExampleView: View {
    let items: [String] // Replace with your model data

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(items, id: \.self) { item in
                    CustomItemView(item: item)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
    }
}

struct CollectionExampleView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionExampleView(items: Array(1...20).map { "Item \($0)" })
    }
}
