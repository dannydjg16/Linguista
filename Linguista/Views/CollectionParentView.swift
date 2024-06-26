//
//  CollectionParentView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import Foundation
import SwiftUI

struct CollectionParentView: View {
    var body: some View {
//        VStack {
//            Text("Header")
//                .font(.largeTitle)
//                .padding()
//            
//            
//            CollectionExampleView(items: Array(1...50).map { "Item \($0)" })
//            
//            Text("Footer")
//                .font(.largeTitle)
//                .padding()
//        }
        NavigationView {
                    ExampleListView(items: predefinedPrompts)
                }
    }
}

struct CollectionParentView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionParentView()
    }
}
