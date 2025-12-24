//
//  BucketListTCAApp.swift
//  BucketListTCA
//
//  Created by hn on 2025/12/5.
//

import ComposableArchitecture
import SwiftUI
import SQLiteData

@main
struct BucketListTCAApp: App {
    static let store = Store(initialState: BucketList.State()) {
        BucketList()
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
            BucketListView(store: Self.store)
        }
    }
}
