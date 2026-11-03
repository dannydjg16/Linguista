//
//  StoryCreationMode.swift
//  Linguista
//
//  Created by Daniel Grant on 10/30/26.
//

import Foundation

enum StoryCreationMode: String, CaseIterable, Identifiable {
    // The model writes a batch of pages from a single idea
    case wholeStory = "Whole Story"
    // The reader describes each page, starting with the first
    case pageByPage = "Page by Page"
    // The reader plans every page up front, then the whole book is written in one go
    case allAtOnce = "All at Once"

    var id: String { rawValue }
}
