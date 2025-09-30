//
//  LocationServiceTests.swift
//  LenzTests
//
//  Created by Michael Setji on 9/30/25.
//

import XCTest
import CoreLocation
@testable import Lenz

@MainActor
final class LocationServiceTests: XCTestCase {
    var locationService: LocationService!

    override func setUp() async throws {
        locationService = LocationService()
    }

    func testLocationService_Initialization() {
        XCTAssertNotNil(locationService)
        XCTAssertNil(locationService.currentLocation)
    }

    func testGeocodeLocation_ValidLocation_ReturnsLocation() async throws {
        let sanFranciscoCoordinate = CLLocation(latitude: 37.7749, longitude: -122.4194)

        let location = try await locationService.geocodeLocation(sanFranciscoCoordinate)

        XCTAssertEqual(location.latitude, 37.7749, accuracy: 0.001)
        XCTAssertEqual(location.longitude, -122.4194, accuracy: 0.001)
        XCTAssertFalse(location.city.isEmpty)
        XCTAssertFalse(location.country.isEmpty)
    }
}