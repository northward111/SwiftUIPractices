//
//  BookwormFeature.swift
//  Bookworm
//
//  Created by hn on 2025/11/19.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct BookwormFeature {
    @ObservableState
    struct State: Equatable {
        var books: IdentifiedArrayOf<Book> = []
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case onAppear
        case refreshBooks
        case deleteBooks(IndexSet)
        case addBookButtonTapped
        case booksUpdated([Book])
        case path(StackActionOf<Path>)
        case bookTapped(Book)
    }
    
    @Dependency(\.databaseService) var databaseService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.refreshBooks)
            case .refreshBooks:
                return .run { send in
                    let store = databaseService.store()
                    let books = await store.fetchBooks()
                    await send(.booksUpdated(books))
                }
            case .booksUpdated(let books):
                state.books = IdentifiedArray(uniqueElements: books)
                return .none
            case .deleteBooks(let indexSet):
                return .run { [books = state.books] send in
                    let toDeleteBooks = books.enumerated().filter { (i, _) in
                        indexSet.contains(i)
                    }.map { $0.1 }
                    let store = databaseService.store()
                    for book in toDeleteBooks {
                        await store.deleteBook(persistentID: book.persistentID!)
                    }
                    await send(.refreshBooks)
                }
            case .bookTapped(let book):
                state.path.append(.detail(.init(book: book)))
                return .none
            case .addBookButtonTapped:
                state.path.append(.addBook(.init()))
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension BookwormFeature {
    @Reducer
    enum Path {
        case detail(DetailFeature)
        case addBook(AddBookFeature)
    }
}

extension BookwormFeature.Path.State: Equatable {}

struct BookwormView: View {
    @Bindable var store: StoreOf<BookwormFeature>
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                ForEach(store.books) { book in
                    Button {
                        store.send(.bookTapped(book))
                    } label: {
                        HStack {
                            EmojiRatingView(rating: book.rating)
                                .font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .if(book.rating == 1, transform: {
                                        $0.foregroundStyle(.red)
                                    })
                                    .font(.headline)
                                Text(book.author)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    store.send(.deleteBooks(indexSet))
                }
            }
            .navigationTitle("Bookworm")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Book", systemImage: "plus") {
                        store.send(.addBookButtonTapped)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        } destination: { store in
            switch store.case {
            case .detail(let childStore):
                DetailView(store: childStore)
            case .addBook(let childStore):
                AddBookView(store: childStore)
            }
        }
    }
}
