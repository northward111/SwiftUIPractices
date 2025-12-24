//
//  WeSplitApp.swift
//  WeSplit
//
//  Created by hn on 2025/7/19.
//

import ComposableArchitecture
import SwiftUI

@main
struct WeSplitApp: App {
    var body: some Scene {
        WindowGroup {
            WeSplitView(store: Store(initialState: WeSplitFeature.State(), reducer: {
                WeSplitFeature()
                    ._printChanges()
            }))
        }
    }
}
