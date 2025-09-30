//
//  LocationService.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine
import CoreLocation

final class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }

    @MainActor
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    @MainActor
    func requestLocation() {
        locationManager.requestLocation()
    }

    @MainActor
    func geocodeLocation(_ location: CLLocation) async throws -> Location {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)

        guard let placemark = placemarks.first else {
            throw LocationError.geocodingFailed
        }

        return Location(
            city: placemark.locality ?? "Unknown City",
            region: placemark.administrativeArea ?? "Unknown Region",
            country: placemark.country ?? "Unknown Country",
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            currentLocation = locations.last
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}

enum LocationError: Error {
    case geocodingFailed
}