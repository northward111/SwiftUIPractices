//
//  PhotoNoteTCAApp.swift
//  PhotoNoteTCA
//
//  Created by hn on 2025/12/5.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@main
struct PhotoNoteTCAApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    
    init() {
        if !isTesting {
            try! prepareDependencies {
                try $0.bootstrapDatabase()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppFeatureView(store: Self.store)
        }
    }
}
