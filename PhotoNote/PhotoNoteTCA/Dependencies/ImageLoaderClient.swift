//
//  ImageLoaderClient.swift
//  PhotoNoteTCA
//
//  Created by hn on 2025/12/6.
//

import ComposableArchitecture
import SwiftUI

struct ImageLoaderClient {
    var loadImage: @Sendable (UUID) async throws -> Image?
}

actor ImageCache {
    private var images: [UUID: Image] = [:]

    func get(_ id: UUID) -> Image? { images[id] }
    func set(_ id: UUID, _ image: Image?) { images[id] = image }
}

extension ImageLoaderClient: DependencyKey {
    static let liveValue = {
        let cache = ImageCache()
        return ImageLoaderClient(
            loadImage: { id in
                if let cached = await cache.get(id) {
                    print("cache hitted \(id)")
                    return cached
                }
                return try await withDependencies({ _ in /* no-op */}) {
                    let deps = DependencyValues._current
                    let assetClient = deps.assetClient
                    let image: Image? = try await Task.detached(priority: .utility) {
                        let data = try assetClient.loadData(id)
                        guard let ui = UIImage(data: data) else { return nil }
                        return Image(uiImage: ui)
                    }.value
                    await cache.set(id, image)
                    return image
                }
            }
        )
    }()

    static let testValue = ImageLoaderClient(
        loadImage: { _ in Image(systemName: "photo") }
    )
}

extension DependencyValues {
    var imageLoaderClient: ImageLoaderClient {
        get { self[ImageLoaderClient.self] }
        set { self[ImageLoaderClient.self] = newValue }
    }
}
