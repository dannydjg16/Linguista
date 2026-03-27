//
//  WordLookupService.swift
//  Linguista
//
//  Created by Daniel Grant on 3/23/26.
//

import Foundation
import SwiftUI

struct WordLookupService {
    static func lookup(_ word: String) async -> WordLookupResult {
        try? await Task.sleep(nanoseconds: 400_000_000)
        let clean = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
        return WordLookupResult(
            word: clean,
            translation: "hello test"
        )
    }
}
