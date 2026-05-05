//
//  StoryViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 5/4/26.
//

import SwiftUI

class StoryViewModel: ObservableObject {
    @Published var pages: [StoryPage] = []
    @Published var currentIndex: Int = -1
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var promptText: String = ""
    @Published var storyStarted: Bool = false

    // 🔁 Swap FakeStoryAPIService() for your real API service here:
    private let apiService: StoryAPIService = FakeStoryAPIService()

    var currentPage: StoryPage? {
        guard currentIndex >= 0, currentIndex < pages.count else { return nil }
        return pages[currentIndex]
    }

    var canGoBack: Bool { currentIndex > 0 }
    var canGoForward: Bool { !isLoading }

    func startStory() async {
        guard !promptText.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a story prompt first."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let page = try await apiService.generateFirstSentence(prompt: promptText)
            pages = [page]
            currentIndex = 0
            storyStarted = true
        } catch {
            errorMessage = "Failed to start story: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func goForward() async {
        // If there's a cached next page, just navigate to it
        if currentIndex < pages.count - 1 {
            currentIndex += 1
            return
        }
        // Otherwise generate a new page
        isLoading = true
        errorMessage = nil
        do {
            let page = try await apiService.generateNextSentence(previousPages: pages)
            pages.append(page)
            currentIndex += 1
        } catch {
            errorMessage = "Failed to generate next page: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func goBack() {
        guard canGoBack else { return }
        currentIndex -= 1
    }
}
