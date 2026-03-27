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

    @State private var selectedIndex: Int? = nil
    @State private var isLoading = false
    @State private var result: WordLookupResult? = nil
    @State private var cachedResults: [String: WordLookupResult] = [:]
    @EnvironmentObject var conversationViewModel: ConversationViewModel

    private var words: [String] {
        message.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    }

    var body: some View {
        WrappingHStack(words: words, selectedIndex: selectedIndex) { index in
            handleTap(index: index)
        }
        .overlayPreferenceValue(WordFrameKey.self) { anchors in
            GeometryReader { geo in
                if let idx = selectedIndex, let anchor = anchors[idx] {
                    let frame = geo[anchor]
                    TooltipBox(isLoading: isLoading, result: result, word: words[idx])
                        .fixedSize()
                        .position(x: clampedX(frame: frame, geo: geo),
                                  y: frame.minY - 10) // sits just above the word
                        .transition(.scale(scale: 0.85, anchor: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selectedIndex)
                }
            }
        }
        // Tap outside to dismiss
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                withAnimation { selectedIndex = nil; result = nil }
            }
        )
    }

    private func clampedX(frame: CGRect, geo: GeometryProxy) -> CGFloat {
        let tooltipWidth: CGFloat = 200
        let padding: CGFloat = 8
        let ideal = frame.midX
        let minX = tooltipWidth / 2 + padding
        let maxX = geo.size.width - tooltipWidth / 2 - padding
        return min(max(ideal, minX), maxX)
    }

    private func handleTap(index: Int) {
        // Tapping the same word dismisses it
        if selectedIndex == index {
            withAnimation { selectedIndex = nil; result = nil }
            return
        }

        withAnimation { selectedIndex = index; result = nil }
        let word = words[index].trimmingCharacters(in: .punctuationCharacters).lowercased()

        if let cached = cachedResults[word] {
            withAnimation { result = cached }
            return
        }

        isLoading = true
        Task {
            let r = await conversationViewModel.translateWord(wordToTranslate: word, contextOfWord: message)
            await MainActor.run {
                cachedResults[word] = r
                isLoading = false
                withAnimation { result = r }
            }
        }
    }
}
