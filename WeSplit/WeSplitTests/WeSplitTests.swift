//
//  WeSplitTests.swift
//  WeSplitTests
//
//  Created by hn on 2025/11/13.
//

import ComposableArchitecture
import Testing

@testable import WeSplit

@MainActor
struct WeSplitTests {
    @Test func checkAmount() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let store = TestStore(initialState: WeSplitFeature.State()) {
            WeSplitFeature()
        }
        await store.send(\.binding, .set(\.checkAmount, 100)) { state in
            state.checkAmount = 100
        }
        #expect(store.state.grandTotal == 120)
        #expect(store.state.totalPerPerson == 60)
    }
    
    @Test func calculationNonExhaustive() async throws {
        let store = TestStore(initialState: WeSplitFeature.State()) {
            WeSplitFeature()
        }
        store.exhaustivity = .off
        await store.send(\.binding, .set(\.checkAmount, 100))
        await store.send(\.binding, .set(\.tipPercentage, 50))
        await store.send(\.binding, .set(\.numberOfPeople, 10))
        store.assert { state in
            state.checkAmount = 100
            state.tipPercentage = 50
            state.numberOfPeople = 10
        }
        #expect(store.state.totalPerPerson == 15)
    }

}
