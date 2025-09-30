//
//  Location.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import CoreLocation

struct Location: Codable, Equatable {
    let city: String
    let region: String
    let country: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case city
        case region
        case country
        case latitude
        case longitude
    }
}