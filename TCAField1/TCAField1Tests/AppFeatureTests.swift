//
//  AppFeatureTests.swift
//  TCAField1Tests
//
//  Created by hn on 2025/11/10.
//

import ComposableArchitecture
import Testing

@testable import TCAField1

@MainActor
struct AppFeatureTests {
    @Test func incrementInFirstTab() async throws {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        await store.send(\.tab1.incrementButtonTapped) {
            $0.tab1.count = 1
        }
        
    }
}
