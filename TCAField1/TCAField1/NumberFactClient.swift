//
//  NumberFactClient.swift
//  TCAField1Tests
//
//  Created by hn on 2025/11/8.
//

import ComposableArchitecture
import Foundation

struct NumberFactClient {
    var fetch: (Int) async throws -> String
}

extension NumberFactClient: DependencyKey {
    static let liveValue: NumberFactClient = Self(
        fetch: { number in
            let (data, _) = try await URLSession.shared.data(from: URL(string: "http://numbersapi.com/\(number)")!)
            return String(decoding: data, as: UTF8.self)
        }
    )
    
    static let testValue: NumberFactClient = Self(
        fetch: { number in "\(number) is a good number." }
    )
}

extension DependencyValues {
    var numberFact: NumberFactClient {
        get {
            self[NumberFactClient.self]
        }
        set {
            self[NumberFactClient.self] = newValue
        }
    }
    
}
