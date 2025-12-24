//
//  InstafilterTCAApp.swift
//  InstafilterTCA
//
//  Created by hn on 2025/12/2.
//

import ComposableArchitecture
import SwiftUI

@main
struct InstafilterTCAApp: App {
    static let store = Store(initialState: Instafilter.State()) {
        Instafilter()
            ._printChanges()
    }
    var body: some Scene {
        WindowGroup {
            InstafilterView(store: Self.store)
        }
    }
}
