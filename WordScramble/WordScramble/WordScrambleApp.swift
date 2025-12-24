//
//  WordScrambleApp.swift
//  WordScramble
//
//  Created by hn on 2025/8/2.
//

import ComposableArchitecture
import SwiftUI

@main
struct WordScrambleApp: App {
    static let store = Store(initialState: WordScrambleFeature.State()) {
        WordScrambleFeature()
            ._printChanges()
    }
    var body: some Scene {
        WindowGroup {
            WordScrambleView(store: WordScrambleApp.store)
        }
    }
}
