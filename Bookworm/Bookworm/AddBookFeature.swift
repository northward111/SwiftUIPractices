//
//  AddBookView.swift
//  Bookworm
//
//  Created by hn on 2025/10/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AddBookFeature {
    static let genres = ["Fantasy", "Horror", "Kids", "Mystery", "Poetry", "Romance", "Thriller"]
    @ObservableState
    struct State: Equatable {
        var title = ""
        var author = ""
        var rating = 3
        var genre = "Fantasy"
        var review = ""
        
        var hasValidInfo: Bool {
            if title.isSemanticallyEmpty || author.isSemanticallyEmpty || genre.isSemanticallyEmpty {
                return false
            }
            return true
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case saveButtonTapped
    }
    
    @Dependency(\.databaseService) var databaseService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .saveButtonTapped:
                let book = Book(title: state.title, author: state.author, genre: state.genre, review: state.review, rating: state.rating)
                return .run { send in
                    let store = databaseService.store()
                    _ = await store.saveBook(book)
                    await dismiss()
                }
            case .binding(let bindingAction):
                print("Binding fired: \(bindingAction)")
                return .none
            }
        }
    }
}

struct AddBookView: View {
    @Bindable var store: StoreOf<AddBookFeature>
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $store.title)
                TextField("Author", text: $store.author)
                
                Picker("Genre", selection: $store.genre) {
                    ForEach(AddBookFeature.genres, id: \.self) {
                        Text($0)
                    }
                }
            }
            
            Section("Write a review") {
                TextEditor(text: $store.review)
                
                RatingView(rating: $store.rating)
            }
            
            Section {
                Button("Save") {
                    store.send(.saveButtonTapped)
                }
                .disabled(store.hasValidInfo == false)
            }
        }
        .navigationTitle("Add Book")
    }
}



//struct AddBookView: View {
//    @Environment(\.modelContext) var modelContext
//    @Environment(\.dismiss) var dismiss
//    @State private var title = ""
//    @State private var author = ""
//    @State private var rating = 3
//    @State private var genre = "Fantasy"
//    @State private var review = ""
//    var hasValidInfo: Bool {
//        if title.isSemanticallyEmpty || author.isSemanticallyEmpty || genre.isSemanticallyEmpty {
//            return false
//        }
//        return true
//    }
//    
//    var body: some View {
//        Form {
//            Section {
//                TextField("Title", text: $title)
//                TextField("Author", text: $author)
//                
//                Picker("Genre", selection: $genre) {
//                    ForEach(genres, id: \.self) {
//                        Text($0)
//                    }
//                }
//            }
//            
//            Section("Write a review") {
//                TextEditor(text: $review)
//                
//                RatingView(rating: $rating)
//            }
//            
//            Section {
//                Button("Save") {
//                    let newBook = Book(title: title, author: author, genre: genre, review: review, rating: rating)
////                    modelContext.insert(newBook)
//                    dismiss()
//                }
//                .disabled(hasValidInfo == false)
//            }
//        }
//        .navigationTitle("Add Book")
//    }
//    
//    
//}

//#Preview {
//    AddBookView()
//}
