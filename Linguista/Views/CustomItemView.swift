//
//  CustomItemView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import Foundation
import SwiftUI

struct CustomItemView: View {
    let item: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(item)
                .font(.headline)
                .padding(.top, 5)
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(8)
        .foregroundColor(.white)
        .padding(.horizontal)
    }
}
