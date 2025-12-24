//
//  BookwormApp.swift
//  Bookworm
//
//  Created by hn on 2025/10/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct BookwormApp: App {
    
    static let store = Store(initialState: BookwormFeature.State()) {
        BookwormFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            BookwormView(store: Self.store)
        }
    }
}
