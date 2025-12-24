//
//  APICleint.swift
//  FriendFaceTCA
//
//  Created by hn on 2025/11/27.
//

import ComposableArchitecture
import Foundation

struct APIClient {
    var fetchUsers: @Sendable () async throws -> [User]
}

private enum APIClientKey: DependencyKey {
    static let liveValue = APIClient(
        fetchUsers: {
            let url = URL(
                string: "https://www.hackingwithswift.com/samples/friendface.json"
            )!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request
                .setValue(
                    "application/json",
                    forHTTPHeaderField: "Content-Type"
                )
            print("load users from network...")
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([User].self, from: data)
        }
    )
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}
