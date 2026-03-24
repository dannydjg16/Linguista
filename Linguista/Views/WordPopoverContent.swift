//
//  WordPopoverContent.swift
//  Linguista
//
//  Created by Daniel Grant on 3/23/26.
//

import SwiftUI

struct WordPopoverContent: View {
    let word: String
    let isLoading: Bool
    let result: WordLookupResult?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "text.magnifyingglass")
                    .foregroundColor(.brown)
                Text("Look Up")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }

            Divider()

            if isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Looking up …")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } else if let r = result {
                // Word + part of speech
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(r.word)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(r.partOfSpeech)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.brown.opacity(0.12))
                        .cornerRadius(4)
                }

                // Syllables
                Text(r.syllables)
                    .font(.caption)
                    .foregroundColor(.brown)
                    .fontWeight(.medium)

                Divider()

                // Definition
                Text(r.definition)
                    .font(.callout)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(minWidth: 220, maxWidth: 300)
    }
}
