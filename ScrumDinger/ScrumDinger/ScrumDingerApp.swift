//
//  ScrumDingerApp.swift
//  ScrumDinger
//
//  Created by hn on 2025/11/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct ScrumDingerApp: App {
    @MainActor
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}
