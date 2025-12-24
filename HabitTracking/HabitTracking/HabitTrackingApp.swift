//
//  HabitTrackingApp.swift
//  HabitTracking
//
//  Created by hn on 2025/10/21.
//

import ComposableArchitecture
import SwiftUI

@main
struct HabitTrackingApp: App {
    static let store = Store(initialState: HabitTrackingFeature.State()) {
        HabitTrackingFeature()
            ._printChanges()
    }
    var body: some Scene {
        WindowGroup {
            HabitTrackingView(store: Self.store)
        }
    }
}
