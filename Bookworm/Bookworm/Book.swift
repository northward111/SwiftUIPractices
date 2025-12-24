//
//  Book.swift
//  Bookworm
//
//  Created by hn on 2025/10/24.
//

import Foundation
import SwiftData

struct Book: Identifiable, Equatable, Sendable {
    var id: UUID
    var persistentID: PersistentIdentifier?
    var title: String
    var author: String
    var genre: String
    var review: String
    var rating: Int
    var date: Date
    
    init(title: String, author: String, genre: String, review: String, rating: Int) {
        self.id = UUID()
        self.persistentID = nil
        self.title = title
        self.author = author
        self.genre = genre
        self.review = review
        self.rating = rating
        self.date = Date.now
    }
    
    @Model
    class Model {
        var title: String
        var author: String
        var genre: String
        var review: String
        var rating: Int
        var date: Date
        
        init(title: String, author: String, genre: String, review: String, rating: Int, date: Date) {
            self.title = title
            self.author = author
            self.genre = genre
            self.review = review
            self.rating = rating
            self.date = date
        }
    }
    
    init(from model: Model) {
        self.id = UUID()
        self.persistentID = model.id
        self.title = model.title
        self.author = model.author
        self.genre = model.genre
        self.review = model.review
        self.rating = model.rating
        self.date = model.date
    }
    
    func toModel() -> Model {
        let model = Model(title: title, author: author, genre: genre, review: review, rating: rating, date: date)
        return model
    }
    
    var hasValidInfo: Bool {
        if title.isSemanticallyEmpty || author.isSemanticallyEmpty || genre.isSemanticallyEmpty {
            return false
        }
        return true
    }
}
