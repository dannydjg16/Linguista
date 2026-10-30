//
//  StoryLibraryService.swift
//  Linguista
//
//  Created by Daniel Grant on 10/30/26.
//

import CoreData

// Saves stories to Core Data, including their images and audio, so they can be re-read offline
@MainActor
struct StoryLibraryService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func isSaved(_ storyID: UUID) -> Bool {
        savedStory(with: storyID) != nil
    }

    // Inserts the story, or updates the saved copy if it's already in the library
    func save(_ story: Story) {
        let savedStory = savedStory(with: story.id) ?? SavedStory(context: context)
        if savedStory.savedAt == nil {
            savedStory.savedAt = Date()
        }
        savedStory.id = story.id
        savedStory.title = story.title
        savedStory.titleTranslation = story.titleTranslation
        savedStory.language = story.language
        savedStory.level = story.level.rawValue
        savedStory.visualStyle = story.visualStyle
        savedStory.characters = story.characters

        let existingPages = (savedStory.pages as? Set<SavedStoryPage>) ?? []
        for (index, page) in story.pages.enumerated() {
            let savedPage = existingPages.first(where: { $0.id == page.id }) ?? SavedStoryPage(context: context)
            savedPage.id = page.id
            savedPage.index = Int16(index)
            savedPage.text = page.text
            savedPage.translation = page.translation
            savedPage.transliteration = page.transliteration
            savedPage.imagePrompt = page.imagePrompt
            savedPage.story = savedStory

            // Only write media when it changes, since large blobs are stored as external files
            if case .loaded(let imageData) = page.imageState, savedPage.imageData != imageData {
                savedPage.imageData = imageData
            }
            if let audioData = page.audioData, savedPage.audioData != audioData {
                savedPage.audioData = audioData
            }
        }

        saveContext()
    }

    func delete(_ storyID: UUID) {
        guard let savedStory = savedStory(with: storyID) else { return }
        delete(savedStory)
    }

    func delete(_ savedStory: SavedStory) {
        context.delete(savedStory)
        saveContext()
    }

    // Rebuilds the in-memory story the reader works with
    static func story(from savedStory: SavedStory) -> Story {
        let savedPages = ((savedStory.pages as? Set<SavedStoryPage>) ?? []).sorted { $0.index < $1.index }

        return Story(
            id: savedStory.id ?? UUID(),
            title: savedStory.title ?? "",
            titleTranslation: savedStory.titleTranslation ?? "",
            language: savedStory.language ?? "",
            level: StoryLevel(rawValue: savedStory.level ?? "") ?? .beginner,
            visualStyle: savedStory.visualStyle ?? "",
            characters: savedStory.characters ?? "",
            pages: savedPages.map { savedPage in
                StoryPage(
                    id: savedPage.id ?? UUID(),
                    text: savedPage.text ?? "",
                    translation: savedPage.translation ?? "",
                    transliteration: savedPage.transliteration,
                    imagePrompt: savedPage.imagePrompt ?? "",
                    // Pages saved before their image finished will be illustrated when they're read
                    imageState: savedPage.imageData.map { .loaded($0) } ?? .notLoaded,
                    audioData: savedPage.audioData
                )
            }
        )
    }

    // MARK: - Helpers

    private func savedStory(with storyID: UUID) -> SavedStory? {
        let request = SavedStory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", storyID as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Error: \(error.localizedDescription)")
            context.rollback()
        }
    }
}
