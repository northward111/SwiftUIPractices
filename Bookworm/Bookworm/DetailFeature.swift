//
//  DetailFeature.swift
//  Bookworm
//
//  Created by hn on 2025/11/19.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct DetailFeature {
    @ObservableState
    struct State: Equatable {
        let book: Book
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action {
        case deleteButtonTapped
        case alert(PresentationAction<Alert>)
        enum Alert: Equatable {
            case sure
        }
    }
    
    @Dependency(\.databaseService) var databaseService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .deleteButtonTapped:
                state.alert = .deleteConfirmation()
            case .alert(.presented(.sure)):
                return .run { [book = state.book] send in
                    let store = databaseService.store()
                    await store.deleteBook(persistentID: book.persistentID!)
                    await dismiss()
                }
            case .alert:
                break
            }
            return .none
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension AlertState where Action == DetailFeature.Action.Alert {
    static func deleteConfirmation() -> Self {
        AlertState {
            TextState("Are you sure?")
        } actions: {
            ButtonState(action: .sure) {
                TextState("Sure")
            }
            ButtonState (role: .cancel) {
                TextState("Cancel")
            }
        }
    }
}

struct DetailView: View {
    let store: StoreOf<DetailFeature>
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottomTrailing) {
                Image(store.book.genre)
                    .resizable()
                    .scaledToFit()

                Text(store.book.genre.uppercased())
                    .font(.caption)
                    .fontWeight(.black)
                    .padding(8)
                    .foregroundStyle(.white)
                    .background(.black.opacity(0.5))
                    .clipShape(.capsule)
                    .offset(x: -5, y: -5)
            }
            Text(store.book.author)
                .font(.title)
                .foregroundStyle(.secondary)
            Text(store.book.review)
                .padding()
            Text(store.book.date, format: .dateTime.day().month().year())
            RatingView(rating: .constant(store.book.rating))
                .font(.largeTitle)
        }
        .navigationTitle(store.book.title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollBounceBehavior(.basedOnSize)
        .toolbar {
            Button("Delete this book", systemImage: "trash") {
                store.send(.deleteButtonTapped)
            }
        }
        .alert(store: store.scope(state: \.$alert, action: \.alert))
    }
}

