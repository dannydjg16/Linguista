//
//  StoryPage.swift
//  Linguista
//
//  Created by Daniel Grant on 4/29/26.
//

import Foundation

struct StoryPage: Identifiable {
    var id = UUID()
    let text: String
    let translation: String
    var transliteration: String?
    let imagePrompt: String
    var imageState: StoryImageState = .notLoaded
    var audioData: Data?
}

enum StoryImageState {
    case notLoaded
    case loading
    case loaded(Data)
    case failed
}
