//
//  MulplicationTablePracticeApp.swift
//  MulplicationTablePractice
//
//  Created by hn on 2025/8/20.
//

import ComposableArchitecture
import SwiftUI

@main
struct MulplicationTablePracticeApp: App {
    static let store = Store(initialState: MultiplicationTablePracticeFeature.State()) {
        MultiplicationTablePracticeFeature()
            ._printChanges()
    }
    var body: some Scene {
        WindowGroup {
            MultiplicationTablePracticeView(store: Self.store)
        }
    }
}
