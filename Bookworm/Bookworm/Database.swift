//
//  Database.swift
//  Bookworm
//
//  Created by hn on 2025/11/20.
//

import Dependencies
import Foundation
import SwiftData

enum Persistence {
    static let container: ModelContainer = {
        do {
            let url = URL.applicationSupportDirectory.appending(path: "Model.sqlite")
            let config = ModelConfiguration(url: url)
            return try ModelContainer(for: Book.Model.self, configurations: config)
        } catch {
            fatalError("Failed to create container.")
        }
    }()
}


struct Database {
    var store: @Sendable () -> ModelStore
}

@ModelActor
actor ModelStore {
    func fetchBooks() -> [Book] {
        do {
            let models = try modelContext.fetch(FetchDescriptor<Book.Model>())
            return models.map { Book(from: $0) }
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func saveBook(_ book: Book) -> Book {
        do {
            let model = book.toModel()
            modelContext.insert(book.toModel())
            try modelContext.save()
            return Book(from: model)
        } catch {
            print(error.localizedDescription)
            return book
        }
    }

    func deleteBook(persistentID: PersistentIdentifier) {
        do {
            // Fetch the model from the context
            if let bookModel = modelContext.model(for: persistentID) as? Book.Model {
                modelContext.delete(bookModel)
                try modelContext.save()
            } else {
                print("No book found with ID \(persistentID)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension Database: DependencyKey {
    static var liveValue: Database = Database {
        ModelStore(modelContainer: Persistence.container)
    }
}

extension DependencyValues {
    var databaseService: Database {
        get { self[Database.self] }
        set { self[Database.self] = newValue }
    }
}
