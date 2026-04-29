//
//  StoryPage.swift
//  Linguista
//
//  Created by Daniel Grant on 4/29/26.
//

import SwiftUI

struct StoryPage: Identifiable {
    let id = UUID()
    let sentence: String
    let imageURL: String? // Replace with your actual image type (e.g. UIImage, URL)
    let imagePrompt: String
}
