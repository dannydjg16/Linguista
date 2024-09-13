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
    
    static func recalculateHeight(height: CGFloat, text: String) -> CGFloat {
        // Use a method to calculate how many lines of text there are
        let numberOfLines = text.split(separator: "\n").count
        let lineHeight: CGFloat = 20 // Approximate line height
        let newHeight = max(40, CGFloat(numberOfLines) * lineHeight) // 40 is the min height
        return min(newHeight, 200) // Limit to max height of 200, adjust as needed
    }
}
