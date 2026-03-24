//
//  MessageBubbleViewWithoutPlayAudioButton.swift
//  Linguista
//
//  Created by Daniel Grant on 3/11/25.
//

//import Foundation
//import SwiftUI
//
//struct MessageBubbleViewWithoutPlayAudioButton: View {
//    
//    let message: String
//    
//    var body: some View {
//        VStack {
//            HStack(alignment: .bottom, spacing: 10) {
//                Text(message)
//                    .padding()
//                    .background(Color.brown.opacity(0.2))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.black.opacity(0.5), lineWidth: 4))
//                    .cornerRadius(10)
//            }
//        }
//    }
//}


import SwiftUI
import Foundation

// MARK: - Anchor Preference for word frames
struct WordFrameKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGRect>] = [:]
    static func reduce(value: inout [Int: Anchor<CGRect>], nextValue: () -> [Int: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// MARK: - Lookup Result Model
struct WordLookupResult {
    let word: String
    let definition: String
    let partOfSpeech: String
}

// MARK: - Lookup Service (swap with your real method)
struct WordLookupService {
    static func lookup(_ word: String) async -> WordLookupResult {
        try? await Task.sleep(nanoseconds: 400_000_000)
        let clean = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
        return WordLookupResult(
            word: clean,
            definition: "Your method result for appears here.",
            partOfSpeech: ["noun", "verb", "adjective"].randomElement()!
        )
    }
}

// MARK: - Tappable Word
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

// MARK: - Tooltip Caption Box
struct TooltipBox: View {
    let isLoading: Bool
    let result: WordLookupResult?
    let word: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if isLoading {
                HStack(spacing: 6) {
                    ProgressView().scaleEffect(0.75)
                    Text("Looking up…")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else if let r = result {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(r.word)
                        .font(.caption)
                        .fontWeight(.bold)
                    Text(r.partOfSpeech)
                        .font(.caption2)
                        .italic()
                        .foregroundColor(.secondary)
                }
                Text(r.definition)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .frame(maxWidth: 200)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.brown.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Wrapping Words View with inline tooltip
struct WrappingWordsView: View {
    let message: String

    @State private var selectedIndex: Int? = nil
    @State private var isLoading = false
    @State private var result: WordLookupResult? = nil
    @State private var cachedResults: [String: WordLookupResult] = [:]

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
            let r = await WordLookupService.lookup(word)
            await MainActor.run {
                cachedResults[word] = r
                isLoading = false
                withAnimation { result = r }
            }
        }
    }
}

// MARK: - Wrapping HStack
struct WrappingHStack: View {
    let words: [String]
    let selectedIndex: Int?
    let onTap: (Int) -> Void

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            buildLayout(in: geo.size.width)
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
                TappableWordView(
                    word: word,
                    index: index,
                    isSelected: selectedIndex == index,
                    onTap: { onTap(index) }
                )
                .font(.body)
                .alignmentGuide(.leading) { d in
                    let wordWidth = d.width + spacing
                    if x + wordWidth > availableWidth && x > 0 {
                        x = 0; y += lineHeight
                    }
                    let result = -x
                    if index == words.count - 1 {
                        x = 0
                        DispatchQueue.main.async { totalHeight = y + lineHeight }
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

// MARK: - Message Bubble
struct MessageBubbleViewWithoutPlayAudioButton: View {
    let message: String

    var body: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 10) {
                WrappingWordsView(message: message)
                    .padding()
                    .background(Color.brown.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.5), lineWidth: 4)
                    )
                    .cornerRadius(10)
            }
        }
    }
}
