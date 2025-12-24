//
//  RequestReviewClient.swift
//  InstafilterTCA
//
//  Created by hn on 2025/12/2.
//

import Dependencies
import StoreKit

struct StoreKitClient {
    var requestReview: @Sendable () async -> Void
}

private enum StoreKitClientKey: DependencyKey {
    static let liveValue = StoreKitClient {
        await MainActor.run {
            SKStoreReviewController.requestReview()
        }
    }
}

extension DependencyValues {
    var storeKitClient: StoreKitClient {
        get { self[StoreKitClientKey.self] }
        set { self[StoreKitClientKey.self] = newValue }
    }
}
