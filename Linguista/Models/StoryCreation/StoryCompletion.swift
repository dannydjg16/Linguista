//
//  StoryCompletion.swift
//  Linguista
//
//  Created by Daniel Grant on 10/22/26.
//

import Foundation

// JSON shapes the completions model is asked to return when writing a story.

struct StoryCompletion: Decodable {
    let title: String
    let titleTranslation: String
    let visualStyle: String
    let characters: String
    let pages: [StoryPageCompletion]
}

struct StoryContinuationCompletion: Decodable {
    let pages: [StoryPageCompletion]
}

struct StoryPageCompletion: Decodable {
    let text: String
    let translation: String
    let transliteration: String?
    let scene: String
}
