import ComposableArchitecture
import Foundation
import IdentifiedCollections
import SQLiteData
import Testing
@testable import FlashzillaTCA

@MainActor
struct DeckReducerTests {
    func seedCards(using database: any DatabaseWriter) -> [Card] {
        let cards = [
            Card(id: UUID(1), prompt: "Capital of France?", answer: "Paris"),
            Card(id: UUID(2), prompt: "2 + 2", answer: "4")
        ]
        withErrorReporting {
            try database.write { db in
                try db.seed {
                    for card in cards {
                        card
                    }
                }
            }
        }
        return cards
    }
    
    @Test("Card removed incorrectly is reinserted at the top")
    func incorrectRemovalRequeuesCard() async throws {
        let (cards, store) = try withDependencies { dependencyValues in
            try dependencyValues.bootstrapDatabase()
            dependencyValues.continuousClock = .immediate
            dependencyValues.uuid = .incrementing
        } operation: {
            @Dependency(\.defaultDatabase) var database
            let cards = seedCards(using: database)
            let store = TestStore(initialState: Deck.State()) {
                Deck()
            }
            return (cards, store)
        }
        
        await store.send(.startAgainButtonTapped) {
            $0.timeRemaining = 100
            $0.isActive = true
            $0.cards = IdentifiedArray(uniqueElements: cards)
            $0.deckID = UUID(0)
        }
        
        await store.send(.onCardRemoval(cards[1], false)) {
            $0.cards.remove(cards[1])
            $0.cards.insert(cards[1], at: 0)
        }
    }
    
//    @Test("Card removed correctly disappears and stops when empty")
//    func correctRemovalRemovesCard() async {
//        var state = Deck.State()
//        state.cards = IdentifiedArray(uniqueElements: [Self.sampleCards[0]])
//        state.isActive = true
//        
//        let store = TestStore(initialState: state) {
//            Deck()
//        }
//        
//        await store.send(.onCardRemoval(Self.sampleCards[0], true)) {
//            $0.cards.remove(Self.sampleCards[0])
//            $0.isActive = false
//        }
//    }
//    
//    @Test("Timer ticks only when active")
//    func timerTickDecrementsWhenActive() async {
//        var state = Deck.State()
//        state.timeRemaining = 2
//        state.isActive = true
//        
//        let store = TestStore(initialState: state) {
//            Deck()
//        }
//        
//        await store.send(.timerTick) {
//            $0.timeRemaining = 1
//        }
//        
//        await store.send(.timerTick) {
//            $0.timeRemaining = 0
//        }
//        
//        await store.send(.timerTick)
//    }
}
