//
//  MapViewModel.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine
import MapKit


class MapViewModel: ObservableObject {
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var cityAnnotations: [CityAnnotation] = []

    private let videoService = VideoService()

    func loadCityAnnotations() async {
        do {
            let videos = try await videoService.fetchVideosNearLocation(
                Location(city: "Unknown", region: "Unknown", country: "Unknown", latitude: 0, longitude: 0),
                radius: 1000.0
            )

            var cityCounts: [String: (Location, Int)] = [:]

            for video in videos {
                let city = video.location.city
                if let existing = cityCounts[city] {
                    cityCounts[city] = (existing.0, existing.1 + 1)
                } else {
                    cityCounts[city] = (video.location, 1)
                }
            }

            cityAnnotations = cityCounts.map { city, data in
                CityAnnotation(
                    city: city,
                    coordinate: data.0.coordinate,
                    videoCount: data.1
                )
            }
        } catch {
            print("Error loading city annotations: \(error)")
        }
    }
}