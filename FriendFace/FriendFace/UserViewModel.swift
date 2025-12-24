//
//  Users.swift
//  FriendFace
//
//  Created by hn on 2025/10/28.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class UserViewModel {
    var users: [User]
    
    init(users: [User]) {
        self.users = users
    }
    
    @MainActor
    func load(modelContext: ModelContext) async {
        guard users.isEmpty else {
            return
        }
        let url = URL(string: "https://www.hackingwithswift.com/samples/friendface.json")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            print("load users from network...")
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            try decoder.decode([UserDTO].self, from: data).forEach {
                let user = User(from: $0)
                modelContext.insert(user)
            }
            try modelContext.save()
        } catch {
            print("Request error: \(error.localizedDescription)")
        }
    }
}
