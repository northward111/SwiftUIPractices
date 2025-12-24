//
//  ContentView.swift
//  Flashzilla
//
//  Created by hn on 2025/11/3.
//

import SwiftData
import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

struct ContentView: View {
    @Query var cards: [Card]
    @State private var cardStore = CardStore()
    var body: some View {
        DeckView(cardStore: cardStore)
            .onAppear(perform: {
                cardStore.cards = cards
            })
            .onChange(of: cards) {
                cardStore.cards = cards
            }
    }
}



struct DeckView: View {
    @Environment(\.scenePhase) var scenePhase
    let cardStore: CardStore
    @State private var cards = Array<Card>()
    @State private var isActive = false
    @State private var showingEditScreen = false
    @State private var timeRemaining = 100
    @State private var deckID = UUID()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            Image(.background)
                .resizable()
                .ignoresSafeArea()
            VStack {
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                
                ZStack {
                    ForEach(cards) { card in
                        let index = cards.firstIndex(of: card)!
                        CardView(card: card) { isRight in
                            withAnimation {
                                removeCard(card: card, isRight: isRight)
                            }
                        }
                        .stacked(at: index, in: cards.count)
                        .allowsHitTesting(index == cards.count - 1)
                    }
                }
                .id(deckID)
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
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
                        showingEditScreen = true
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
        .onReceive(timer) { time in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                if cards.isEmpty == false {
                    isActive = true
                }
            }else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
            EditCards(cardStore: cardStore)
        }
        .onAppear(perform: resetCards)
    }
    
    func removeCard(card: Card, isRight: Bool) {
        print("Remove: \(card.description)")
        guard let index = cards.firstIndex(of: card) else {
            fatalError("Bad card: \(card.description)")
        }
        cards.remove(at: index)
        if isRight == false {
            cards.insert(card, at: 0)
        }
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData()
        deckID = UUID()
    }
    
    func loadData() {
        cards = cardStore.cards
    }
}

#Preview {
    ContentView()
}
