//
//  BetterRestApp.swift
//  BetterRest
//
//  Created by hn on 2025/7/31.
//

import ComposableArchitecture
import SwiftUI

@main
struct BetterRestApp: App {
    var body: some Scene {
        WindowGroup {
            BetterRestView(store: Store(initialState: BetterRestFeature.State(), reducer: {
                BetterRestFeature()
            }))
        }
    }
}
