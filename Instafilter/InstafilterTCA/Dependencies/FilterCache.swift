//
//  FilterCache.swift
//  InstafilterTCA
//
//  Created by hn on 2025/12/2.
//

import CoreImage
import Dependencies

import Dependencies

struct ImageCacheClient {
    var setImage: @Sendable (CIImage?) async -> Void
    var getImage: @Sendable () async -> CIImage?
    
    
}

private enum ImageCacheClientKey: DependencyKey {
    static let liveValue = {
        let cache = ImageCache()
        return ImageCacheClient { image in
            await cache.setImage(image)
        } getImage: {
            await cache.getImage()
        }
    }()
}

extension DependencyValues {
    var imageCacheClient: ImageCacheClient {
        get { self[ImageCacheClientKey.self] }
        set { self[ImageCacheClientKey.self] = newValue }
    }
}

actor ImageCache {
    private var image: CIImage?
    
    func getImage() -> CIImage? {
        image
    }
    
    func setImage(_ image: CIImage?) {
        self.image = image
    }
}
