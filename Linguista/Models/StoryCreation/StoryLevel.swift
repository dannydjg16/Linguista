//
//  StoryLevel.swift
//  Linguista
//
//  Created by Daniel Grant on 10/22/26.
//

import Foundation

enum StoryLevel: String, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var id: String { rawValue }

    var promptDescription: String {
        switch self {
        case .beginner:
            return "a beginner level. Use very short, simple sentences in the present tense with common, everyday words."
        case .intermediate:
            return "an intermediate level. Use clear sentences with some past and future tense and moderately common vocabulary."
        case .advanced:
            return "an advanced level. Use natural, varied sentences and rich vocabulary, as a native speaker would."
        }
    }
}
