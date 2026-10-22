//
//  StoryViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 5/4/26.
//

import SwiftUI

@MainActor
class StoryViewModel: ObservableObject {
    @Published var story: Story?
    @Published var currentPageIndex = 0
    @Published var promptText = ""
    @Published var level: StoryLevel = .beginner
    @Published var showTranslation = false
    @Published var isGeneratingStory = false
    @Published var isContinuingStory = false
    @Published var loadingAudioPageID: UUID?
    @Published var errorMessage: String?

    private let completionsService = CompletionsService.shared
    private let ttsViewModel = TtsViewModel()
    private let pagesPerRequest = 6

    var isOnLastPage: Bool {
        guard let story else { return false }
        return currentPageIndex == story.pages.count - 1
    }

    // MARK: - Story Generation

    func generateStory(language: String, surpriseMe: Bool) async {
        let idea = promptText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !surpriseMe && idea.isEmpty {
            errorMessage = "Tell us what the story should be about, or tap Surprise Me."
            return
        }

        isGeneratingStory = true
        errorMessage = nil
        defer { isGeneratingStory = false }

        let messages = [
            Message(role: "system", content: newStorySystemPrompt(language: language)),
            Message(role: "user", content: surpriseMe ? "Invent an original, delightful story idea and write it." : "Story idea: \(idea)")
        ]

        do {
            let completion: StoryCompletion = try await fetchJSONCompletion(messages: messages)
            guard !completion.pages.isEmpty else { throw URLError(.cannotParseResponse) }

            story = Story(
                title: completion.title,
                titleTranslation: completion.titleTranslation,
                language: language,
                level: level,
                visualStyle: completion.visualStyle,
                characters: completion.characters,
                pages: completion.pages.map {
                    makePage(from: $0, visualStyle: completion.visualStyle, characters: completion.characters)
                }
            )
            currentPageIndex = 0
            loadImages(around: 0)
        } catch {
            print("Error: \(error.localizedDescription)")
            errorMessage = "Something went wrong writing your story. Please try again."
        }
    }

    func continueStory() async {
        guard let existingStory = story, !isContinuingStory else { return }

        isContinuingStory = true
        errorMessage = nil
        defer { isContinuingStory = false }

        let storySoFar = existingStory.pages.enumerated()
            .map { "\($0.offset + 1). \($0.element.text)" }
            .joined(separator: "\n")
        let messages = [
            Message(role: "system", content: continuationSystemPrompt(story: existingStory)),
            Message(role: "user", content: "Story so far:\n\(storySoFar)")
        ]

        do {
            let completion: StoryContinuationCompletion = try await fetchJSONCompletion(messages: messages)
            guard !completion.pages.isEmpty else { throw URLError(.cannotParseResponse) }

            // The user may have started a new story while this one was being continued
            guard story?.id == existingStory.id else { return }

            let firstNewPageIndex = existingStory.pages.count
            story?.pages.append(contentsOf: completion.pages.map {
                makePage(from: $0, visualStyle: existingStory.visualStyle, characters: existingStory.characters)
            })
            withAnimation { currentPageIndex = firstNewPageIndex }
            loadImages(around: firstNewPageIndex)
        } catch {
            print("Error: \(error.localizedDescription)")
            errorMessage = "Couldn't continue the story. Please try again."
        }
    }

    func reset() {
        ttsViewModel.audioPlayer?.stop()
        story = nil
        currentPageIndex = 0
        promptText = ""
        showTranslation = false
        errorMessage = nil
    }

    // MARK: - Navigation

    func goToNextPage() {
        guard let story, currentPageIndex < story.pages.count - 1 else { return }
        currentPageIndex += 1
    }

    func goToPreviousPage() {
        guard currentPageIndex > 0 else { return }
        currentPageIndex -= 1
    }

    // MARK: - Images

    // Images are slow to generate, so only the visible page and the one after it are requested
    func loadImages(around index: Int) {
        guard let story else { return }
        for pageIndex in [index, index + 1] where story.pages.indices.contains(pageIndex) {
            let page = story.pages[pageIndex]
            if case .notLoaded = page.imageState {
                loadImage(for: page.id)
            }
        }
    }

    func retryImage(for pageID: UUID) {
        loadImage(for: pageID)
    }

    private func loadImage(for pageID: UUID) {
        guard let page = story?.pages.first(where: { $0.id == pageID }) else { return }
        if case .loading = page.imageState { return }

        updatePage(pageID) { $0.imageState = .loading }
        let imageRequest = ImageRequest(model: selectedImageModel, prompt: page.imagePrompt, size: storyImageSize)

        Task {
            do {
                let imageData = try await completionsService.fetchImage(imageRequest: imageRequest)
                updatePage(pageID) { $0.imageState = .loaded(imageData) }
            } catch {
                print("Error: \(error.localizedDescription)")
                updatePage(pageID) { $0.imageState = .failed }
            }
        }
    }

    // MARK: - Audio

    func playAudio(for pageID: UUID) async {
        if let audioData = await loadAudio(for: pageID) {
            ttsViewModel.playAudio(with: audioData)
        }
    }

    // Fetches the page's audio once and keeps it on the page for replays
    @discardableResult
    func loadAudio(for pageID: UUID) async -> Data? {
        guard let page = story?.pages.first(where: { $0.id == pageID }) else { return nil }

        if let audioData = page.audioData {
            return audioData
        }

        loadingAudioPageID = pageID
        defer { loadingAudioPageID = nil }

        do {
            let ttsRequest = TtsRequest(model: selectedTtsModel, input: page.text, voice: "echo", speed: 0.8)
            let audioData = try await ttsViewModel.fetchTts(ttsRequest: ttsRequest)
            updatePage(pageID) { $0.audioData = audioData }
            return audioData
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Helpers

    private func updatePage(_ pageID: UUID, _ update: (inout StoryPage) -> Void) {
        guard let index = story?.pages.firstIndex(where: { $0.id == pageID }) else { return }
        update(&story!.pages[index])
    }

    private func makePage(from completion: StoryPageCompletion, visualStyle: String, characters: String) -> StoryPage {
        // Repeating the style and character descriptions keeps every illustration consistent
        let imagePrompt = "\(visualStyle) Characters: \(characters) Scene: \(completion.scene) Do not include any text, letters, or words in the image."
        let transliteration = completion.text.containsOnlyLatinLetters ? nil : completion.transliteration

return StoryPage(
            text: completion.text,
            translation: completion.translation,
            transliteration: transliteration,
            imagePrompt: imagePrompt
        )
    }

    private func fetchJSONCompletion<T: Decodable>(messages: [Message]) async throws -> T {
        let dataModel = CompletionsRequest(model: selectedCompletionsModel, messages: messages, maxTokens: maxCompletionTokens, topP: 1)
        let response = try await completionsService.fetchCompletion(completionRequest: dataModel)

        // Models sometimes wrap JSON in a markdown code block, so only decode the object itself
        guard let content = response.choices?.first?.message.content,
              let start = content.firstIndex(of: "{"),
              let end = content.lastIndex(of: "}") else {
            throw URLError(.cannotParseResponse)
        }

        return try JSONDecoder().decode(T.self, from: Data(content[start...end].utf8))
    }

    // MARK: - Prompts

    private func newStorySystemPrompt(language: String) -> String {
        """
        You write short illustrated stories for people learning \(language). Write the story in \(language) at \(level.promptDescription)
        Every page must show one clear, visual moment that moves the story forward, so the picture helps the reader understand the words.
        Respond with only a JSON object and no other text, in exactly this format:
        {"title": "the title in \(language)", "titleTranslation": "the English translation of the title", "visualStyle": "one sentence describing a single illustration style to use for every picture", "characters": "a short description of what each main character looks like, so they are drawn the same way on every page", "pages": [\(pageFormat(language: language))]}
        Write exactly \(pagesPerRequest) pages.
        """
    }

    private func continuationSystemPrompt(story: Story) -> String {
        """
        You are continuing a short illustrated story called "\(story.title)" for people learning \(story.language). Keep writing in \(story.language) at \(story.level.promptDescription)
        Keep the same characters: \(story.characters)
        Every page must show one clear, visual moment that moves the story forward, so the picture helps the reader understand the words.
        Respond with only a JSON object and no other text, in exactly this format:
        {"pages": [\(pageFormat(language: story.language))]}
        Write exactly \(pagesPerRequest) new pages that follow on from the story so far.
        """
    }

    private func pageFormat(language: String) -> String {
        """
        {"text": "one or two sentences of the story in \(language)", "translation": "the English translation of text", "transliteration": "text written in the Latin alphabet, or null if \(language) uses the Latin alphabet", "scene": "an English description of only what is visible on this page, for the illustrator"}
        """
    }
}
