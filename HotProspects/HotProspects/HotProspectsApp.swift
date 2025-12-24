//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by hn on 2025/11/1.
//

import SwiftData
import SwiftUI

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Prospect.self)
    }
}
