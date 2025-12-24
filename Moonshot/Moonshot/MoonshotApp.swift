//
//  MoonshotApp.swift
//  Moonshot
//
//  Created by hn on 2025/10/11.
//

import ComposableArchitecture
import SwiftUI

@main
struct MoonshotApp: App {
    static let store = Store(initialState: MoonshotFeature.State()) {
        MoonshotFeature()
            ._printChanges()
    }
    var body: some Scene {
        WindowGroup {
            MoonshotView(store: Self.store)
        }
    }
}
