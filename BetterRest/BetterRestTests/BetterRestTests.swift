//
//  BetterRestTests.swift
//  BetterRestTests
//
//  Created by hn on 2025/11/14.
//

import ComposableArchitecture
import Testing

@testable import BetterRest

@MainActor
struct BetterRestTests {
    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let store = TestStore(initialState: BetterRestFeature.State()) {
            BetterRestFeature()
        } withDependencies: {
            $0.sleepCalculatorClient = SleepCalculatorClient(predict: { wake, sleep, coffee in
                8 * 3600
            })
        }
        await store.send(.binding(.set(\.sleepAmount, 9))) {
            $0.sleepAmount = 9
        }
        await store.receive(\.predictionResponse) {
            $0.showedBedtime = "23:00"
        }
    }

}
