//
//  WrappingWordsView.swift
//  Linguista
//
//  Created by Daniel Grant on 3/23/26.
//

import Foundation
import SwiftUI

struct WrappingWordsView: View {
    let message: String

    private var words: [String] {
        message.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    }

    var body: some View {
        // Use a flow-layout approach via GeometryReader + manual wrapping
        WrappingHStack(words: words)
    }
}
