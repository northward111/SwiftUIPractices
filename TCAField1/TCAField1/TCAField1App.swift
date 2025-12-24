//
//  TCAField1App.swift
//  TCAField1
//
//  Created by hn on 2025/11/8.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCAField1App: App {
    static let store = Store(initialState: ContactsFeature.State(), reducer: {
        ContactsFeature()
            ._printChanges()
    })
    var body: some Scene {
        WindowGroup {
            ContactsView(store: TCAField1App.store)
        }
    }
}
