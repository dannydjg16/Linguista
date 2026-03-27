//
//  TooltipBox.swift
//  Linguista
//
//  Created by Daniel Grant on 3/24/26.
//

import SwiftUI
import Foundation

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
                    Text(r.translation)
                        .font(.caption2)
                        .italic()
                        .foregroundColor(.secondary)
                }
                Text(r.translation)
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
