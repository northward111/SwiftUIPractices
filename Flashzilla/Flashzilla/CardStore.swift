//
//  CardStore.swift
//  Flashzilla
//
//  Created by hn on 2025/11/4.
//

import Foundation

@Observable
class CardStore {
    static let cardsPath = "cards.json"
    var cards: [Card] = []
}
