//
//  RecipeUmApp.swift
//  RecipeUm
//
//  Created by 이선민 on 8/24/26.
//

import SwiftUI
import SwiftData

@main
struct RecipeUmApp: App {
    var sharedModelContainer: ModelContainer = RecipeUmModelContainerFactory.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

private enum RecipeUmModelContainerFactory {
    private static let schema = Schema([
        Recipe.self,
        IngredientGroup.self,
        RecipeIngredient.self,
        CookingStep.self,
        RecipeSource.self,
    ])

    static func make() -> ModelContainer {
        do {
            return try persistentContainer()
        } catch {
            do {
                try removePersistentStore()
                return try persistentContainer()
            } catch {
                assertionFailure("Falling back to in-memory storage after persistent store recovery failed: \(error)")
                return inMemoryContainer()
            }
        }
    }

    private static func persistentContainer() throws -> ModelContainer {
        let storeURL = try persistentStoreURL()
        let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }

    private static func inMemoryContainer() -> ModelContainer {
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            preconditionFailure("Could not create fallback ModelContainer: \(error)")
        }
    }

    private static func persistentStoreURL() throws -> URL {
        let applicationSupportURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directoryURL = applicationSupportURL.appendingPathComponent("RecipeUm", isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL.appendingPathComponent("RecipeUm.store")
    }

    private static func removePersistentStore() throws {
        let storeURL = try persistentStoreURL()
        let fileManager = FileManager.default

        for url in [
            storeURL,
            storeURL.appendingPathExtension("shm"),
            storeURL.appendingPathExtension("wal"),
        ] where fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
}
