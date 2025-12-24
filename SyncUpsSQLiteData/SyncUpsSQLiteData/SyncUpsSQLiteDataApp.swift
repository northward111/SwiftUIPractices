//
//  SyncUpsSQLiteDataApp.swift
//  SyncUpsSQLiteData
//
//  Created by hn on 2025/11/30.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@main
struct SyncUpsSQLiteDataApp: App {
    
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
            AppView(store: Self.store)
        }
    }
}
