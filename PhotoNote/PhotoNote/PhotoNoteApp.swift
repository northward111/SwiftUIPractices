//
//  PhotoNoteApp.swift
//  PhotoNote
//
//  Created by hn on 2025/10/31.
//

import SwiftData
import SwiftUI

@main
struct PhotoNoteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PhotoNote.self)
    }
}
