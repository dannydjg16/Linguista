//
//  Story.swift
//  Linguista
//
//  Created by Daniel Grant on 10/22/26.
//

import Foundation

struct Story: Identifiable {
    var id = UUID()
    var title: String
    var titleTranslation: String
    let language: String
    let level: StoryLevel
    // Shared across every image prompt so the illustrations look like one book
    let visualStyle: String
    let characters: String
    var pages: [StoryPage]
}
