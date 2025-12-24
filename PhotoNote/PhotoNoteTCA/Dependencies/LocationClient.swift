//
//  LocationClient.swift
//  PhotoNoteTCA
//
//  Created by hn on 2025/12/6.
//

import ComposableArchitecture
import CoreLocation

public struct LocationClient {
    public var requestAuthorization: () -> Void
    public var startUpdatingLocation: () -> Void
    public var stopUpdatingLocation: () -> Void
    
    public var locationUpdates: () -> AsyncStream<LocationEvent>
    public var authorizationStatus: () -> AsyncStream<CLAuthorizationStatus>
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

public enum LocationEvent: Equatable {
    case update(CLLocationCoordinate2D, accuracy: CLLocationAccuracy)
    case error(LocationError)
}

public enum LocationError: Equatable, Error {
    case denied
    case restricted
    case unableToDetermine
    case unableToFetch
}

extension DependencyValues {
    public var locationClient: LocationClient {
        get { self[LocationClientKey.self] }
        set { self[LocationClientKey.self] = newValue }
    }
}

private enum LocationClientKey: DependencyKey {
    static let liveValue = LocationClient.live
    static let testValue = LocationClient.unimplemented
}

extension LocationClient {
    static let live: LocationClient = {
        let manager = CLLocationManager()
        let delegate = LocationManagerDelegate()
        manager.delegate = delegate
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        return LocationClient(
            requestAuthorization: {
                manager.requestWhenInUseAuthorization()
            },
            
            startUpdatingLocation: {
                manager.startUpdatingLocation()
            },
            
            stopUpdatingLocation: {
                manager.stopUpdatingLocation()
            },
            
            locationUpdates: {
                delegate.locationStream()
            },
            
            authorizationStatus: {
                delegate.authorizationStream()
            }
        )
    }()
}

extension LocationClient {
    static let unimplemented = LocationClient(
        requestAuthorization: { XCTFail("unimplemented") },
        startUpdatingLocation: { XCTFail("unimplemented") },
        stopUpdatingLocation: { XCTFail("unimplemented") },
        locationUpdates: { fatalError("unimplemented") },
        authorizationStatus: { fatalError("unimplemented") }
    )
}

final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    private var locationContinuation: AsyncStream<LocationEvent>.Continuation?
    private var authorizationContinuation: AsyncStream<CLAuthorizationStatus>.Continuation?

    func locationStream() -> AsyncStream<LocationEvent> {
        AsyncStream { continuation in
            locationContinuation = continuation
        }
    }
    
    func authorizationStream() -> AsyncStream<CLAuthorizationStatus> {
        AsyncStream { continuation in
            authorizationContinuation = continuation
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        authorizationContinuation?.yield(status)
        
        switch status {
        case .denied:
            locationContinuation?.yield(.error(.denied))
        case .restricted:
            locationContinuation?.yield(.error(.restricted))
        default:
            break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else {
            locationContinuation?.yield(.error(.unableToFetch))
            return
        }

        locationContinuation?.yield(
            .update(location.coordinate, accuracy: location.horizontalAccuracy)
        )
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        locationContinuation?.yield(.error(.unableToDetermine))
    }
}
