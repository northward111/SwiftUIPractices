//
//  FlashzillaTCAApp.swift
//  FlashzillaTCA
//
//  Created by hn on 2025/12/5.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@main
struct FlashzillaTCAApp: App {
    static let store = Store(initialState: Deck.State()) {
        Deck()
//            ._printChanges()
    }
    
    init() {
        if !isTesting {
            try! prepareDependencies {
                try $0.bootstrapDatabase()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            DeckView(store: Self.store )
        }
    }
}
