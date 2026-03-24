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

    @State private var showPopover = false
    @State private var isLoading = false
    @State private var result: WordLookupResult?

    var body: some View {
        Text(word)
            .foregroundColor(.primary)
            .background(
                showPopover
                    ? Color.brown.opacity(0.35)
                    : Color.clear
            )
            .cornerRadius(3)
            .onTapGesture {
                showPopover = true
                if result == nil {
                    isLoading = true
                    Task {
                        let r = await WordLookupService.lookup(word)
                        await MainActor.run {
                            result = r
                            isLoading = false
                        }
                    }
                }
            }
            .popover(isPresented: $showPopover, arrowEdge: .top) {
                WordPopoverContent(
                    word: word,
                    isLoading: isLoading,
                    result: result
                )
            }
    }
}
