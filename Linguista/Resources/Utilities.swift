//
//  Utilities.swift
//  Linguista
//
//  Created by Daniel Grant on 9/5/24.
//

import Foundation

struct Utilities {
    
    static func getLanguageName(by id: Int) -> String {
        return popularLanguageObjects.first { $0.id == id }!.name
    }
    
}

extension Character {
    var isLatinLetter: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        let name = scalar.properties.name ?? ""
        return name.contains("LATIN")
    }
}

extension String {
    /// Returns `true` if every alphabetic character is from the Latin script
    /// (allows digits, punctuation, spaces, emojis, symbols — only cares about letters)
    var containsOnlyLatinLetters: Bool {
        // Skip non-letter characters entirely
        return allSatisfy { char in
            !char.isLetter || char.isLatinLetter
        }
    }
}
