//
//  ContentView.swift
//  FlashzillaTCA
//
//  Created by hn on 2025/12/5.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct Deck {
    @Reducer
    enum Destination {
        case editCards(EditCards)
    }
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var timeRemaining = 100
        var cards: IdentifiedArrayOf<Card> = []
        var deckID = UUID()
        var isActive = false
        var isInitialized = false
    }
    
    enum Action {
        case editButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case cancelEditButtonTapped
        case onCardRemoval(Card, Bool)
        case startAgainButtonTapped
        case onAppear
        case timerTick
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
            case .editButtonTapped:
                state.destination = .editCards(EditCards.State())
                return .none
            case .cancelEditButtonTapped:
                state.destination = nil
                return .none
            case let .onCardRemoval(card, isRight):
                state.cards.remove(card)
                if isRight == false {
                    state.cards.insert(card, at: 0)
                }
                if state.cards.isEmpty {
                    state.isActive = false
                }
                return .none
            case .startAgainButtonTapped:
                resetCards(state: &state)
                return .none
            case .onAppear:
                if state.isInitialized == false {
                    state.isInitialized = true
                    resetCards(state: &state)
                    return .run { send in
                        for await _ in clock.timer(interval: .seconds(1)) {
                            await send(.timerTick)
                        }
                    }
                }else {
                    return .none
                }
            case .timerTick:
                guard state.isActive else {
                    return .none
                }
                if state.timeRemaining > 0 {
                    state.timeRemaining -= 1
                }
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
    
    func resetCards(state: inout State) {
        state.timeRemaining = 100
        state.isActive = true
        loadCards(state: &state)
        state.deckID = uuid()
    }
    
    func loadCards(state: inout State) {
        withErrorReporting {
            let cards = try database.read({ db in
                try Card.fetchAll(db)
            })
            state.cards = IdentifiedArray(uniqueElements: cards)
        }
    }
}

extension Deck.Destination.State: Equatable {}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

struct DeckView: View {
    @Environment(\.scenePhase) var scenePhase
    @Bindable var store: StoreOf<Deck>
    var body: some View {
        ZStack {
            Image(.background)
                .resizable()
                .ignoresSafeArea()
            VStack {
                Text("Time: \(store.timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                
                ZStack {
                    ForEach(store.cards) { card in
                        let index = store.cards.firstIndex(of: card)!
                        CardView(card: card) { isRight in
                            withAnimation {
                                _ = store.send(.onCardRemoval(card, isRight))
                            }
                        }
                        .stacked(at: index, in: store.cards.count)
                        .allowsHitTesting(index == store.cards.count - 1)
                    }
                }
                .id(store.deckID)
                .allowsHitTesting(store.timeRemaining > 0)
                
                if store.cards.isEmpty {
                    Button("Start Again") {
                        store.send(.startAgainButtonTapped)
                    }
                    .padding()
                    .background(.white)
                    .foregroundStyle(.black)
                    .clipShape(.capsule)
                }
            }
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        store.send(.editButtonTapped)
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(.circle)
                    }
                }
                
                Spacer()
            }
            .foregroundStyle(.white)
            .font(.largeTitle)
            .padding()
        }
        .sheet(item: $store.scope(state: \.destination?.editCards, action: \.destination.editCards)) { editStore in
            NavigationStack {
                EditCardsView(store: editStore)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                store.send(.cancelEditButtonTapped)
                            }
                        }
                    }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
