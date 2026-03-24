//
//  TappableWordView.swift
//  Linguista
//
//  Created by Daniel Grant on 3/23/26.
//

import Foundation
import SwiftUI

struct TappableWordView: View {
    let word: String
    let index: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(word)
            .foregroundColor(.primary)
            .background(isSelected ? Color.brown.opacity(0.3) : Color.clear)
            .cornerRadius(3)
            .anchorPreference(key: WordFrameKey.self, value: .bounds) { [index: $0] }
            .onTapGesture { onTap() }
    }
}
