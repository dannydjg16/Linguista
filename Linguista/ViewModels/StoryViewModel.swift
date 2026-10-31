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
    @Published var creationMode: StoryCreationMode = .wholeStory
    @Published var pictureContextText = ""
    @Published var level: StoryLevel = .beginner
    @Published var showTranslation = false
    @Published var isGeneratingStory = false
    @Published var isContinuingStory = false
    @Published var isAddingPage = false
    @Published var loadingAudioPageID: UUID?
    @Published var errorMessage: String?
    @Published var isSaved = false

    private let completionsService = CompletionsService.shared
    private let ttsViewModel = TtsViewModel()
    private let storyLibrary = StoryLibraryService()
    private let pagesPerRequest = 10

    init() {}

    // Opens a story from the library to re-read
    init(savedStory: Story) {
        story = savedStory
        isSaved = true
        loadImages(around: 0)
        // Covers stories saved before their transliterations were filled in
        Task { await fillMissingTransliterations() }
    }

    var canDeleteCurrentPage: Bool {
        guard let story else { return false }
        // A story needs at least one page, and pages can't shift while new ones are being written
        return story.pages.count > 1 && !isContinuingStory && !isAddingPage
    }

    var isOnLastPage: Bool {
        guard let story else { return false }
        return currentPageIndex == story.pages.count - 1
    }

    // MARK: - Story Generation

    func generateStory(language: String, surpriseMe: Bool) async {
        let idea = promptText.trimmingCharacters(in: .whitespacesAndNewlines)
        let isPageByPage = creationMode == .pageByPage
        if !surpriseMe && idea.isEmpty {
            errorMessage = isPageByPage
                ? "Tell us what happens on the first page, or tap Surprise Me."
                : "Tell us what the story should be about, or tap Surprise Me."
            return
        }

        isGeneratingStory = true
        errorMessage = nil
        defer { isGeneratingStory = false }

        let pictureContext = isPageByPage ? trimmedPictureContext(pictureContextText) : nil
        var request: String
        if isPageByPage {
            request = surpriseMe ? "Invent an original, delightful story idea and write its first page." : "What happens on the first page: \(idea)"
            if let pictureContext {
                request += "\nPicture context: \(pictureContext)"
            }
        } else {
            request = surpriseMe ? "Invent an original, delightful story idea and write it." : "Story idea: \(idea)"
        }
        let messages = [
            Message(role: "system", content: newStorySystemPrompt(language: language, pageCount: isPageByPage ? 1 : pagesPerRequest, isReaderDirected: isPageByPage)),
            Message(role: "user", content: request)
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
                    makePage(from: $0, visualStyle: completion.visualStyle, characters: completion.characters, pictureContext: pictureContext)
                }
            )
            currentPageIndex = 0
            isSaved = false
            loadImages(around: 0)
            Task { await fillMissingTransliterations() }
        } catch {
            print("Error: \(error.localizedDescription)")
            errorMessage = "Something went wrong writing your story. Please try again."
        }
    }

    func continueStory() async {
        guard let existingStory = story, !isContinuingStory, !isAddingPage else { return }

        isContinuingStory = true
        errorMessage = nil
        defer { isContinuingStory = false }

        let messages = [
            Message(role: "system", content: continuationSystemPrompt(story: existingStory, pageCount: pagesPerRequest, isReaderDirected: false)),
            Message(role: "user", content: "Story so far:\n\(storySoFar(existingStory))")
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
            persistIfSaved()
            loadImages(around: firstNewPageIndex)
            Task { await fillMissingTransliterations() }
        } catch {
            print("Error: \(error.localizedDescription)")
            errorMessage = "Couldn't continue the story. Please try again."
        }
    }

    // Writes a single page from the reader's own idea, unlike continueStory, which writes several on its own.
    // Returns whether the page was added, so the composer knows when to close.
    func addPage(idea: String, pictureContext: String) async -> Bool {
        guard let existingStory = story, !isAddingPage, !isContinuingStory else { return false }

        isAddingPage = true
        errorMessage = nil
        defer { isAddingPage = false }

        let trimmedIdea = idea.trimmingCharacters(in: .whitespacesAndNewlines)
        let pictureContext = trimmedPictureContext(pictureContext)
        var request = "Story so far:\n\(storySoFar(existingStory))\n\n"
        request += trimmedIdea.isEmpty ? "Continue the story naturally." : "What happens on the next page: \(trimmedIdea)"
        if let pictureContext {
            request += "\nPicture context: \(pictureContext)"
        }
        let messages = [
            Message(role: "system", content: continuationSystemPrompt(story: existingStory, pageCount: 1, isReaderDirected: true)),
            Message(role: "user", content: request)
        ]

        do {
            let completion: StoryContinuationCompletion = try await fetchJSONCompletion(messages: messages)
            guard let pageCompletion = completion.pages.first else { throw URLError(.cannotParseResponse) }

            // The user may have started a new story while this page was being written
            guard story?.id == existingStory.id else { return false }

            let newPageIndex = existingStory.pages.count
            story?.pages.append(makePage(from: pageCompletion, visualStyle: existingStory.visualStyle, characters: existingStory.characters, pictureContext: pictureContext))
            withAnimation { currentPageIndex = newPageIndex }
            persistIfSaved()
            loadImages(around: newPageIndex)
            Task { await fillMissingTransliterations() }
            return true
        } catch {
            print("Error: \(error.localizedDescription)")
            errorMessage = "Couldn't write that page. Please try again."
            return false
        }
    }

    func reset() {
        ttsViewModel.audioPlayer?.stop()
        story = nil
        currentPageIndex = 0
        promptText = ""
        pictureContextText = ""
        showTranslation = false
        errorMessage = nil
        isSaved = false
    }

    func deleteCurrentPage() {
        guard canDeleteCurrentPage, let story, story.pages.indices.contains(currentPageIndex) else { return }

        // Any audio playing belongs to the page on screen, which is the one being deleted
        ttsViewModel.audioPlayer?.stop()

        withAnimation {
            self.story?.pages.remove(at: currentPageIndex)
            // Deleting the last page moves back one; otherwise the following page takes its place
            currentPageIndex = min(currentPageIndex, (self.story?.pages.count ?? 1) - 1)
        }
        persistIfSaved()
        loadImages(around: currentPageIndex)
    }

    // MARK: - Library

    func toggleSaved() {
        guard let story else { return }
        if isSaved {
            storyLibrary.delete(story.id)
            isSaved = false
        } else {
            storyLibrary.save(story)
            isSaved = true
            // Illustrate every page so the saved copy is complete, not just the pages read so far
            for page in story.pages {
                if case .notLoaded = page.imageState {
                    loadImage(for: page.id)
                }
            }
        }
    }

    // Images, audio, and new pages that arrive after saving are added to the saved copy
    private func persistIfSaved() {
        guard isSaved, let story else { return }
        storyLibrary.save(story)
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
                persistIfSaved()
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
            persistIfSaved()
            return audioData
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Transliteration

    // The story model sometimes leaves out the transliteration or repeats the original script,
    // so ask for the missing ones in a single follow-up request
    private func fillMissingTransliterations() async {
        guard let story else { return }
        let pagesNeedingTransliteration = story.pages.filter {
            $0.transliteration == nil && !$0.text.containsOnlyLatinLetters
        }
        guard !pagesNeedingTransliteration.isEmpty else { return }

        let numberedTexts = pagesNeedingTransliteration.enumerated()
            .map { "\($0.offset + 1). \($0.element.text)" }
            .joined(separator: "\n")
        let messages = [
            Message(role: "system", content: transliterationSystemPrompt(language: story.language, count: pagesNeedingTransliteration.count)),
            Message(role: "user", content: numberedTexts)
        ]

        do {
            let completion: TransliterationCompletion = try await fetchJSONCompletion(messages: messages)
            guard completion.transliterations.count == pagesNeedingTransliteration.count else {
                throw URLError(.cannotParseResponse)
            }

            for (page, transliteration) in zip(pagesNeedingTransliteration, completion.transliterations) {
                if let transliteration = validTransliteration(transliteration) {
                    updatePage(page.id) { $0.transliteration = transliteration }
                }
            }
            persistIfSaved()
        } catch {
            // Pages fall back to the original script, so the story is still readable
            print("Error: \(error.localizedDescription)")
        }
    }

    private func validTransliteration(_ transliteration: String?) -> String? {
        guard let trimmed = transliteration?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty, trimmed.containsOnlyLatinLetters else { return nil }
        return trimmed
    }

    // MARK: - Helpers

    private func updatePage(_ pageID: UUID, _ update: (inout StoryPage) -> Void) {
        guard let index = story?.pages.firstIndex(where: { $0.id == pageID }) else { return }
        update(&story!.pages[index])
    }

    private func makePage(from completion: StoryPageCompletion, visualStyle: String, characters: String, pictureContext: String? = nil) -> StoryPage {
        // Repeating the style and character descriptions keeps every illustration consistent
        var imagePrompt = "\(visualStyle) Characters: \(characters) Scene: \(completion.scene)"
        // The reader's own picture context is added word for word so the model can't drop it
        if let pictureContext {
            imagePrompt += " The picture must also show: \(pictureContext)."
        }
        imagePrompt += " Do not include any text, letters, or words in the image."
        let transliteration = completion.text.containsOnlyLatinLetters ? nil : validTransliteration(completion.transliteration)

return StoryPage(
            text: completion.text,
            translation: completion.translation,
            transliteration: transliteration,
            imagePrompt: imagePrompt
        )
    }

    private func storySoFar(_ story: Story) -> String {
        story.pages.enumerated()
            .map { "\($0.offset + 1). \($0.element.text)" }
            .joined(separator: "\n")
    }

    private func trimmedPictureContext(_ pictureContext: String) -> String? {
        let trimmed = pictureContext.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
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

    private func newStorySystemPrompt(language: String, pageCount: Int, isReaderDirected: Bool) -> String {
        """
        You write short illustrated stories for people learning \(language). Write the story in \(language) at \(level.promptDescription)
        Every page must show one clear, visual moment that moves the story forward, so the picture helps the reader understand the words.
        \(isReaderDirected ? readerDirectedGuidance(language: language) : "")
        Respond with only a JSON object and no other text, in exactly this format:
        {"title": "the title in \(language)", "titleTranslation": "the English translation of the title", "visualStyle": "one sentence describing a single illustration style to use for every picture", "characters": "a short description of what each main character looks like, so they are drawn the same way on every page", "pages": [\(pageFormat(language: language))]}
        \(pageCount == 1 ? "Write exactly 1 page, the first page of the story." : "Write exactly \(pageCount) pages.")
        """
    }

    private func continuationSystemPrompt(story: Story, pageCount: Int, isReaderDirected: Bool) -> String {
        """
        You are continuing a short illustrated story called "\(story.title)" for people learning \(story.language). Keep writing in \(story.language) at \(story.level.promptDescription)
        Keep the same characters: \(story.characters)
        Every page must show one clear, visual moment that moves the story forward, so the picture helps the reader understand the words.
        \(isReaderDirected ? readerDirectedGuidance(language: story.language) : "")
        Respond with only a JSON object and no other text, in exactly this format:
        {"pages": [\(pageFormat(language: story.language))]}
        \(pageCount == 1 ? "Write exactly 1 new page that follows on from the story so far." : "Write exactly \(pageCount) new pages that follow on from the story so far.")
        """
    }

    private func readerDirectedGuidance(language: String) -> String {
        """
        The reader is building this story one page at a time and tells you what happens on the page. Write the page about what they describe. If they wrote it in \(language), use their words as the page text, correcting only mistakes. If they give picture context, make the scene show it.
        """
    }

    private func transliterationSystemPrompt(language: String, count: Int) -> String {
        """
        You transliterate \(language) into the Latin alphabet for English speakers learning \(language). Spell each sentence the way it is pronounced, including vowels the script leaves out, using plain Latin letters.
        Respond with only a JSON object and no other text, in exactly this format:
        {"transliterations": ["the transliteration of line 1", "the transliteration of line 2"]}
        Return exactly \(count) transliterations, one per numbered line, in order. Do not include the line numbers.
        """
    }

    private func pageFormat(language: String) -> String {
        """
        {"text": "one or two sentences of the story in \(language)", "translation": "the English translation of text", "transliteration": "text written in the Latin alphabet, or null if \(language) uses the Latin alphabet", "scene": "an English description of only what is visible on this page, for the illustrator"}
        """
    }
}
