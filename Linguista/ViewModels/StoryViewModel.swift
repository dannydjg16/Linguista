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
    // An optional title the reader picks before the story is written
    @Published var customTitleText = ""
    @Published var isRenamingStory = false
    // Pages whose text or picture is being changed from the page editor
    @Published var editingPageIDs: Set<UUID> = []
    @Published var creationMode: StoryCreationMode = .wholeStory
    @Published var pictureContextText = ""
    // The pages planned in All at Once mode, kept here so they survive switching modes
    @Published var pageDrafts: [StoryPageDraft] = [StoryPageDraft()]
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
    // The latest image request for each page, so an older request that finishes late can't replace a newer picture
    private var imageRequestIDs: [UUID: UUID] = [:]

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

        // Picture context only goes into the image prompt (see makePage), never to the text model,
        // so it can't change what the page says
        let pictureContext = isPageByPage ? trimmedPictureContext(pictureContextText) : nil
        let request: String
        if isPageByPage {
            request = surpriseMe ? "Invent an original, delightful story idea and write its first page." : "What happens on the first page: \(idea)"
        } else {
            request = surpriseMe ? "Invent an original, delightful story idea and write it." : "Story idea: \(idea)"
        }
        let messages = [
            Message(role: "system", content: newStorySystemPrompt(language: language, pageCount: isPageByPage ? 1 : pagesPerRequest, mode: isPageByPage ? .pageByPage : .wholeStory, customTitle: trimmedCustomTitle)),
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

    // Writes every planned page in a single request, so the pages read as one story.
    // Only the page ideas reach the text model; each page's picture context goes straight into its image prompt.
    func generateBook(language: String) async {
        let drafts = pageDrafts.filter { !$0.isEmpty }
        guard drafts.contains(where: \.hasIdea) else {
            errorMessage = "Describe what happens on at least one page."
            return
        }

        isGeneratingStory = true
        errorMessage = nil
        defer { isGeneratingStory = false }

        let pagePlan = drafts.enumerated().map { index, draft in
            let idea = draft.idea.trimmingCharacters(in: .whitespacesAndNewlines)
            return "Page \(index + 1): \(idea.isEmpty ? "(no description, continue the story naturally)" : idea)"
        }.joined(separator: "\n")
        let messages = [
            Message(role: "system", content: newStorySystemPrompt(language: language, pageCount: drafts.count, mode: .allAtOnce, customTitle: trimmedCustomTitle)),
            Message(role: "user", content: pagePlan)
        ]

        do {
            let completion: StoryCompletion = try await fetchJSONCompletion(messages: messages)
            // Picture contexts are matched to pages by position, so a different count would put them on the wrong pages
            guard completion.pages.count == drafts.count else { throw URLError(.cannotParseResponse) }

            story = Story(
                title: completion.title,
                titleTranslation: completion.titleTranslation,
                language: language,
                level: level,
                visualStyle: completion.visualStyle,
                characters: completion.characters,
                pages: zip(completion.pages, drafts).map { page, draft in
                    makePage(from: page, visualStyle: completion.visualStyle, characters: completion.characters,
                             pictureContext: trimmedPictureContext(draft.pictureContext))
                }
            )
            currentPageIndex = 0
            isSaved = false
            loadImages(around: 0)
            Task { await fillMissingTransliterations() }
        } catch {
            print("Error: \(error.localizedDescription)")
            errorMessage = "Something went wrong writing your book. Please try again."
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
        // Picture context only goes into the image prompt (see makePage), never to the text model
        let pictureContext = trimmedPictureContext(pictureContext)
        var request = "Story so far:\n\(storySoFar(existingStory))\n\n"
        request += trimmedIdea.isEmpty ? "Continue the story naturally." : "What happens on the next page: \(trimmedIdea)"
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
        customTitleText = ""
        pictureContextText = ""
        pageDrafts = [StoryPageDraft()]
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

    // Pass force to start a new picture even while one is still being drawn, such as after the page is edited
    private func loadImage(for pageID: UUID, force: Bool = false) {
        guard let page = story?.pages.first(where: { $0.id == pageID }) else { return }
        if case .loading = page.imageState, !force { return }

        let requestID = UUID()
        imageRequestIDs[pageID] = requestID
        updatePage(pageID) { $0.imageState = .loading }
        let imageRequest = ImageRequest(model: selectedImageModel, prompt: page.imagePrompt, size: storyImageSize)

        Task {
            do {
                let imageData = try await completionsService.fetchImage(imageRequest: imageRequest)
                guard imageRequestIDs[pageID] == requestID else { return }
                updatePage(pageID) { $0.imageState = .loaded(imageData) }
                persistIfSaved()
            } catch {
                print("Error: \(error.localizedDescription)")
                guard imageRequestIDs[pageID] == requestID else { return }
                updatePage(pageID) { $0.imageState = .failed }
            }
        }
    }

    // MARK: - Page Editing

    // Draws a new picture for the page from the same prompt
    func redrawImage(for pageID: UUID) {
        loadImage(for: pageID, force: true)
    }

    // Changes a page's text, its picture, or both. The text model only ever sees the text change;
    // the picture change goes only into the image prompt, so it can't alter the words.
    // Returns whether the edit was applied, so the editor knows when to close.
    func editPage(_ pageID: UUID, textChange: String, pictureChange: String, redrawForNewText: Bool) async -> Bool {
        guard let existingStory = story,
              let pageIndex = existingStory.pages.firstIndex(where: { $0.id == pageID }),
              !editingPageIDs.contains(pageID) else { return false }

        let textChange = textChange.trimmingCharacters(in: .whitespacesAndNewlines)
        let pictureChange = pictureChange.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textChange.isEmpty || !pictureChange.isEmpty else { return false }

        editingPageIDs.insert(pageID)
        errorMessage = nil
        defer { editingPageIDs.remove(pageID) }

        let page = existingStory.pages[pageIndex]

        do {
            var revisedPage: StoryPageCompletion?
            if !textChange.isEmpty {
                let messages = [
                    Message(role: "system", content: pageRevisionSystemPrompt(story: existingStory)),
                    Message(role: "user", content: """
                        Story so far:
                        \(storySoFar(existingStory))

                        Rewrite page \(pageIndex + 1). Its current text is: \(page.text)
                        The change the reader wants: \(textChange)
                        """)
                ]
                let completion: StoryContinuationCompletion = try await fetchJSONCompletion(messages: messages)
                guard let first = completion.pages.first else { throw URLError(.cannotParseResponse) }
                revisedPage = first
            }

            // The picture follows the new text only if the reader asked for it
            let newScene = redrawForNewText ? revisedPage?.scene : nil
            var newImagePrompt: String?
            if newScene != nil || !pictureChange.isEmpty {
                newImagePrompt = try await revisedImagePrompt(page.imagePrompt, newScene: newScene,
                                                              pictureChange: pictureChange.isEmpty ? nil : pictureChange)
            }

            // The user may have started a new story or deleted the page while it was being edited
            guard story?.id == existingStory.id, story?.pages.contains(where: { $0.id == pageID }) == true else { return false }

            if let revisedPage {
                updatePage(pageID) {
                    $0.text = revisedPage.text
                    $0.translation = revisedPage.translation
                    $0.transliteration = revisedPage.text.containsOnlyLatinLetters ? nil : validTransliteration(revisedPage.transliteration)
                    // The old recording reads the old words
                    $0.audioData = nil
                }
                Task { await fillMissingTransliterations() }
            }
            if let newImagePrompt {
                updatePage(pageID) { $0.imagePrompt = newImagePrompt }
                loadImage(for: pageID, force: true)
            }
            persistIfSaved()
            return true
        } catch {
            print("Error: \(error.localizedDescription)")
            errorMessage = "Couldn't change that page. Please try again."
            return false
        }
    }

    // Updates the existing prompt rather than rebuilding it, so earlier picture changes and the shared style survive
    private func revisedImagePrompt(_ currentPrompt: String, newScene: String?, pictureChange: String?) async throws -> String {
        var request = "Current illustration prompt:\n\(currentPrompt)\n"
        if let newScene {
            request += "\nThe page's text changed. The scene should now be: \(newScene)"
        }
        if let pictureChange {
            request += "\nThe change the reader wants to the picture: \(pictureChange)"
        }
        let messages = [
            Message(role: "system", content: imagePromptRevisionSystemPrompt),
            Message(role: "user", content: request)
        ]

        let completion: ImagePromptCompletion = try await fetchJSONCompletion(messages: messages)
        var prompt = completion.imagePrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { throw URLError(.cannotParseResponse) }
        let noTextRule = "Do not include any text, letters, or words in the image."
        if !prompt.contains(noTextRule) {
            prompt += " \(noTextRule)"
        }
        return prompt
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

    // MARK: - Title

    private var trimmedCustomTitle: String? {
        let trimmed = customTitleText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    // Renames the story. The new title can be typed in English or the story's language;
    // the model puts it into the story's language and writes the English translation shown under it.
    func renameStory(to newTitle: String) async {
        let newTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let existingStory = story, !newTitle.isEmpty, newTitle != existingStory.title else { return }

        isRenamingStory = true
        errorMessage = nil
        defer { isRenamingStory = false }

        let messages = [
            Message(role: "system", content: titleSystemPrompt(language: existingStory.language)),
            Message(role: "user", content: newTitle)
        ]

        do {
            let completion: TitleCompletion = try await fetchJSONCompletion(messages: messages)
            let title = completion.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { throw URLError(.cannotParseResponse) }

            // The user may have started a new story while this one was being renamed
            guard story?.id == existingStory.id else { return }
            story?.title = title
            story?.titleTranslation = completion.titleTranslation.trimmingCharacters(in: .whitespacesAndNewlines)
            persistIfSaved()
        } catch {
            print("Error: \(error.localizedDescription)")
            errorMessage = "Couldn't rename the story. Please try again."
        }
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

    private func newStorySystemPrompt(language: String, pageCount: Int, mode: StoryCreationMode, customTitle: String?) -> String {
        let guidance: String
        let pageInstruction: String
        switch mode {
        case .wholeStory:
            guidance = ""
            pageInstruction = "Write exactly \(pageCount) pages."
        case .pageByPage:
            guidance = readerDirectedGuidance(language: language)
            pageInstruction = "Write exactly 1 page, the first page of the story."
        case .allAtOnce:
            guidance = plannedBookGuidance(language: language)
            pageInstruction = "Write exactly \(pageCount) pages, one for each numbered page in the reader's plan, in the same order."
        }

        return """
        You write short illustrated stories for people learning \(language). Write the story in \(language) at \(level.promptDescription)
        Every page must show one clear, visual moment that moves the story forward, so the picture helps the reader understand the words.
        \(guidance)
        \(customTitle.map { titleGuidance(customTitle: $0, language: language) } ?? "")
        Respond with only a JSON object and no other text, in exactly this format:
        {"title": "the title in \(language)", "titleTranslation": "the English translation of the title", "visualStyle": "one sentence describing a single illustration style to use for every picture", "characters": "a short description of what each main character looks like, so they are drawn the same way on every page", "pages": [\(pageFormat(language: language))]}
        \(pageInstruction)
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
        The reader is building this story one page at a time and tells you what happens on the page. Write the page about what they describe. If they wrote it in \(language), use their words as the page text, correcting only mistakes.
        """
    }

    private func titleGuidance(customTitle: String, language: String) -> String {
        """
        The reader chose the title "\(customTitle)". Use it as the story's title. If it isn't in \(language), translate it into \(language); otherwise keep their words, correcting only mistakes.
        """
    }

    private func titleSystemPrompt(language: String) -> String {
        """
        You set the title of a short illustrated story written in \(language) for people learning \(language). The reader will send the title they want.
        If it isn't in \(language), translate it into \(language); otherwise keep their words, correcting only mistakes.
        Respond with only a JSON object and no other text, in exactly this format:
        {"title": "the title in \(language)", "titleTranslation": "the English translation of the title"}
        """
    }

    private func pageRevisionSystemPrompt(story: Story) -> String {
        """
        You are revising one page of a short illustrated story called "\(story.title)" for people learning \(story.language). Write in \(story.language) at \(story.level.promptDescription)
        Keep the same characters: \(story.characters)
        Rewrite only the page the reader names, applying the change they describe, so it still fits the pages around it. If they wrote the new text in \(story.language), use their words as the page text, correcting only mistakes.
        Respond with only a JSON object and no other text, in exactly this format:
        {"pages": [\(pageFormat(language: story.language))]}
        Write exactly 1 page.
        """
    }

    private var imagePromptRevisionSystemPrompt: String {
        """
        You maintain the prompt used to draw one illustration in an illustrated story. You will get the current prompt and the changes to make.
        Rewrite the prompt so the picture reflects the changes. Keep the illustration style and character descriptions exactly as they are, and keep every other detail that the changes don't contradict.
        Respond with only a JSON object and no other text, in exactly this format:
        {"imagePrompt": "the full revised prompt"}
        """
    }

    private func plannedBookGuidance(language: String) -> String {
        """
        The reader has planned the whole book and describes what happens on each numbered page. Write each page about what they describe for it, and connect the pages so they read as one story. If they wrote a description in \(language), use their words as that page's text, correcting only mistakes. Never merge, split, skip, or add pages.
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
