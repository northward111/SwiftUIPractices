//
//  FriendFaceApp.swift
//  FriendFace
//
//  Created by hn on 2025/10/28.
//

import SwiftData
import SwiftUI

@main
struct FriendFaceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: User.self)
    }
}
