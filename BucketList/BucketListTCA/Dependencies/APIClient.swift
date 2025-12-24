//
//  APIClient.swift
//  BucketListTCA
//
//  Created by hn on 2025/12/5.
//

import CoreLocation
import Dependencies
import Foundation

enum FetchPlacesError: Error {
    case url(String)
    case network(String)
}

struct APIClient {
    var fetchNearbyPlaces: @Sendable (CLLocationCoordinate2D) async -> Result<[Page], FetchPlacesError>
}

private enum APIClientKey: DependencyKey {
    static let liveValue = APIClient { coordinate in
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(coordinate.latitude)%7C\(coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            return .failure(.url(urlString))
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(NearByPlacesResult.self, from: data)
            let pages = result.query.pages.values.sorted()
            return .success(pages)
        } catch {
            print("network error: \(error.localizedDescription)")
            return .failure(.network(error.localizedDescription))
        }
    }
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}
