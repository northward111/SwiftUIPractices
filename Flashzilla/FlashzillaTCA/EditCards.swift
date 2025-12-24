//
//  EditCards.swift
//  FlashzillaTCA
//
//  Created by hn on 2025/12/13.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct EditCards {
    @ObservableState
    struct State: Equatable {
        var newPrompt = ""
        var newAnswer = ""
        @FetchAll
        var cards: [Card]
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addCardButtonTapped
        case removeCards(IndexSet)
    }
    
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .addCardButtonTapped:
                withErrorReporting {
                    try database.write { db in
                        let draft = Card.Draft(prompt: state.newPrompt, answer: state.newAnswer)
                        try Card.insert {
                            draft
                        }
                        .execute(db)
                    }
                }
                state.newPrompt = ""
                state.newAnswer = ""
                return .none
            case .removeCards(let indices):
                let ids = indices.map { state.cards[$0].id }
                withErrorReporting {
                    try database.write { db in
                        try Card.delete().where {
                            $0.id.in(ids)
                        }
                        .execute(db)
                    }
                }
                return .none
            }
        }
    }
}

struct EditCardsView: View {
    @Bindable var store: StoreOf<EditCards>
    var body: some View {
        List {
            Section("Add new card") {
                TextField("Prompt", text: $store.newPrompt)
                TextField("Answer", text: $store.newAnswer)
                Button("Add Card") {
                    store.send(.addCardButtonTapped)
                }
            }

            Section {
                ForEach(store.cards) { card in
                    VStack(alignment: .leading) {
                        Text(card.prompt)
                            .font(.headline)
                        Text(card.answer)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete { indices in
                    store.send(.removeCards(indices))
                }
            }
        }
        .navigationTitle("Edit Cards")
    }
}

