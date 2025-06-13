//
//  LinguistaApp.swift
//  Linguista
//
//  Created by Daniel Grant on 6/7/24.
//

import SwiftUI
import AVFoundation

@main
struct LinguistaApp: App {
    @StateObject private var conversationViewModel = ConversationViewModel()
    @StateObject private var accountManager = AccountManager()
    let persistenceController = PersistenceController.shared


    init() {
        setupAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(conversationViewModel)
                .environmentObject(accountManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
}

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoreDataPersistence2") // Match your .xcdatamodeld file name
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
