//
//  FlashzillaApp.swift
//  Flashzilla
//
//  Created by hn on 2025/11/3.
//

import SwiftData
import SwiftUI

@main
struct FlashzillaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Card.self)
    }
}
