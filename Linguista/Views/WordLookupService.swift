////
////  WordLookupService.swift
////  Linguista
////
////  Created by Daniel Grant on 3/23/26.
////
//
//import Foundation
//import SwiftUI
//
//struct WordLookupService {
//    static func lookup(_ word: String) async -> WordLookupResult {
//        // Replace this with your real method/API call
//        try? await Task.sleep(nanoseconds: 400_000_000)
//        let clean = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
//        return WordLookupResult(
//            word: clean,
//            definition: "A word meaning '\(clean)'. Replace this with your real lookup logic.",
//            partOfSpeech: ["noun", "verb", "adjective", "adverb"].randomElement()!,
//            syllables: clean.map { String($0) }.joined(separator: "·")
//        )
//    }
//}
