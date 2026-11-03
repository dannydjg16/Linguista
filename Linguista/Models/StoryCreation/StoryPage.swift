//
//  StoryPage.swift
//  Linguista
//
//  Created by Daniel Grant on 4/29/26.
//

import Foundation

struct StoryPage: Identifiable {
    var id = UUID()
    var text: String
    var translation: String
    var transliteration: String?
    var imagePrompt: String
    var imageState: StoryImageState = .notLoaded
    var audioData: Data?
}

enum StoryImageState {
    case notLoaded
    case loading
    case loaded(Data)
    case failed
}
