//
//  FeedViewModel.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine


class FeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var currentVideoIndex = 0

    private let videoService = VideoService()
    private let rankingService = RankingService()

    func loadVideos(locationService: LocationService) async {
        isLoading = true
        defer { isLoading = false }

        guard let currentLocation = locationService.currentLocation else {
            return
        }

        do {
            let location = try await locationService.geocodeLocation(currentLocation)
            let fetchedVideos = try await videoService.fetchVideosNearLocation(location)
            videos = rankingService.rankVideos(fetchedVideos, userLocation: location)
        } catch {
            print("Error loading videos: \(error)")
        }
    }
}