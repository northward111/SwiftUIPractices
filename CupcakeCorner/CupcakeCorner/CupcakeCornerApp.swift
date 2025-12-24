//
//  CupcakeCornerApp.swift
//  CupcakeCorner
//
//  Created by hn on 2025/10/23.
//

import ComposableArchitecture
import SwiftUI

@main
struct CupcakeCornerApp: App {
    static let store = Store(initialState: CupcakeCornerFeature.State()) {
        CupcakeCornerFeature()
            ._printChanges()
    }
    var body: some Scene {
        WindowGroup {
            ContentView(store: Self.store)
        }
    }
}
