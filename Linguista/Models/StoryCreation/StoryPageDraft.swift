//
//  StoryPageDraft.swift
//  Linguista
//
//  Created by Daniel Grant on 10/31/26.
//

import Foundation

// One page the reader has planned before the book is written
struct StoryPageDraft: Identifiable, Equatable {
    var id = UUID()
    // What happens on the page; this is all the text model sees
    var idea = ""
    // What the picture should show; only ever goes into the image prompt
    var pictureContext = ""

    var hasIdea: Bool {
        !idea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isEmpty: Bool {
        !hasIdea && pictureContext.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
