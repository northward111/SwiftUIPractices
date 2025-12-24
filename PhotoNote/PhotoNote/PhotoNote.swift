//
//  PhotoNote.swift
//  PhotoNote
//
//  Created by hn on 2025/10/31.
//

import CoreLocation
import Foundation
import SwiftData
import UIKit

@Model
class PhotoNote {
    var name: String
    @Attribute(.externalStorage) var photo: Data
    var latitude: Double?
    var longitude: Double?
    
    init(name: String, photo: Data, latitude: Double? = nil, longitude: Double? = nil) {
        self.name = name
        self.photo = photo
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var uiimageRepresentation: UIImage? {
        UIImage(data: photo)
    }
    
    var coordinate: CLLocationCoordinate2D? {
        if let latitude, let longitude {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }else {
            nil
        }
    }
    
    static func example() -> PhotoNote {
        PhotoNote(name: "Example", photo: Data())
    }
}


