//
//  WrappingHStack.swift
//  Linguista
//
//  Created by Daniel Grant on 3/23/26.
//

import SwiftUI
import Foundation

struct WrappingHStack: View {
    let words: [String]
    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            self.buildLayout(in: geo.size.width)
        }
        .frame(height: totalHeight)
    }

    private func buildLayout(in availableWidth: CGFloat) -> some View {
        var x: CGFloat = 0
        var y: CGFloat = 0
        let spacing: CGFloat = 4
        let lineHeight: CGFloat = 22

        return ZStack(alignment: .topLeading) {
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                TappableWordView(word: word)
                    .font(.body)
                    .alignmentGuide(.leading) { d in
                        let wordWidth = d.width + spacing
                        if x + wordWidth > availableWidth && x > 0 {
                            x = 0
                            y += lineHeight
                        }
                        let result = -x
                        if index == words.count - 1 {
                            x = 0
                            DispatchQueue.main.async {
                                totalHeight = y + lineHeight
                            }
                        } else {
                            x += wordWidth
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in -y }
            }
        }
    }
}
