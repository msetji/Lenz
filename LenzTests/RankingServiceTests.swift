//
//  RankingServiceTests.swift
//  LenzTests
//
//  Created by Michael Setji on 9/30/25.
//

import XCTest
import CoreLocation
@testable import Lenz

@MainActor
final class RankingServiceTests: XCTestCase {
    var rankingService: RankingService!

    override func setUp() async throws {
        rankingService = RankingService()
    }

    func testRankVideos_SameCity_ShouldPrioritizeNearbyVideos() {
        let userLocation = Location(
            city: "San Francisco",
            region: "California",
            country: "USA",
            latitude: 37.7749,
            longitude: -122.4194
        )

        let nearbyVideo = createVideo(
            city: "San Francisco",
            latitude: 37.7750,
            longitude: -122.4195,
            likes: 10,
            comments: 5
        )

        let farVideo = createVideo(
            city: "Los Angeles",
            latitude: 34.0522,
            longitude: -118.2437,
            likes: 10,
            comments: 5
        )

        let videos = [farVideo, nearbyVideo]
        let rankedVideos = rankingService.rankVideos(videos, userLocation: userLocation)

        XCTAssertEqual(rankedVideos.first?.id, nearbyVideo.id)
    }

    func testRankVideos_HigherEngagement_ShouldRankHigher() {
        let userLocation = Location(
            city: "San Francisco",
            region: "California",
            country: "USA",
            latitude: 37.7749,
            longitude: -122.4194
        )

        let popularVideo = createVideo(
            city: "San Francisco",
            latitude: 37.7750,
            longitude: -122.4195,
            likes: 100,
            comments: 50
        )

        let unpopularVideo = createVideo(
            city: "San Francisco",
            latitude: 37.7751,
            longitude: -122.4196,
            likes: 5,
            comments: 2
        )

        let videos = [unpopularVideo, popularVideo]
        let rankedVideos = rankingService.rankVideos(videos, userLocation: userLocation)

        XCTAssertEqual(rankedVideos.first?.id, popularVideo.id)
    }

    private func createVideo(
        city: String,
        latitude: Double,
        longitude: Double,
        likes: Int,
        comments: Int
    ) -> Video {
        Video(
            id: UUID(),
            userId: UUID(),
            videoURL: "https://example.com/video.mp4",
            thumbnailURL: nil,
            location: Location(
                city: city,
                region: "California",
                country: "USA",
                latitude: latitude,
                longitude: longitude
            ),
            likesCount: likes,
            commentsCount: comments,
            createdAt: Date(),
            user: nil
        )
    }
}