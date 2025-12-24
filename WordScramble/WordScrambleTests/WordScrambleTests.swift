//
//  WordScrambleTests.swift
//  WordScrambleTests
//
//  Created by hn on 2025/11/16.
//

import ComposableArchitecture
import Testing

@testable import WordScramble

@MainActor
struct WordScrambleTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let store = TestStore(initialState: WordScrambleFeature.State()) {
            WordScrambleFeature()
        } withDependencies: {
            $0.randomClient = RandomClient { array in
                array[0]
            }
        }
        
        await store.send(.onAppear) {
            $0.rootWord = "aardvark"
        }
        
        await store.send(.binding(.set(\.newWord, "dark"))) {
            $0.newWord = "dark"
        }
        
        await store.send(.onSubmit) {
            $0.score = 4
            $0.usedWords = ["dark"]
            $0.newWord = ""
        }
    }
}
