//
//  LocationFetcher.swift
//  PhotoNote
//
//  Created by hn on 2025/10/31.
//

import CoreLocation

class LocationFetcher: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var lastKnownLocation: CLLocationCoordinate2D?
    
    var lastKnownLocationDescription: String {
        guard let lastKnownLocation = lastKnownLocation else { return "Unknown" }
        return "\(lastKnownLocation.latitude),\(lastKnownLocation.longitude)"
    }

    override init() {
        super.init()
        manager.delegate = self
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
}


