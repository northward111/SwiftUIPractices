//
//  FriendFaceTCAApp.swift
//  FriendFaceTCA
//
//  Created by hn on 2025/11/26.
//

import ComposableArchitecture
import SwiftUI

@main
struct FriendFaceTCAApp: App {
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
