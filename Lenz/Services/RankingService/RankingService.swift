//
//  RankingService.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine
import CoreLocation


class RankingService: ObservableObject {
    func rankVideos(_ videos: [Video], userLocation: Location) -> [Video] {
        return videos.sorted { video1, video2 in
            let score1 = calculateScore(for: video1, userLocation: userLocation)
            let score2 = calculateScore(for: video2, userLocation: userLocation)
            return score1 > score2
        }
    }

    private func calculateScore(for video: Video, userLocation: Location) -> Double {
        let distanceScore = calculateDistanceScore(
            from: userLocation.coordinate,
            to: video.location.coordinate
        )

        let engagementScore = Double(video.likesCount) * 2.0 + Double(video.commentsCount) * 3.0

        let recencyScore = calculateRecencyScore(for: video.createdAt)

        return (distanceScore * 0.4) + (engagementScore * 0.4) + (recencyScore * 0.2)
    }

    private func calculateDistanceScore(from userCoord: CLLocationCoordinate2D, to videoCoord: CLLocationCoordinate2D) -> Double {
        let userLocation = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        let videoLocation = CLLocation(latitude: videoCoord.latitude, longitude: videoCoord.longitude)
        let distance = userLocation.distance(from: videoLocation) / 1000.0

        if distance <= 10 {
            return 100.0
        } else if distance <= 50 {
            return 80.0
        } else if distance <= 100 {
            return 50.0
        } else {
            return 20.0
        }
    }

    private func calculateRecencyScore(for date: Date) -> Double {
        let hoursSinceCreation = Date().timeIntervalSince(date) / 3600

        if hoursSinceCreation <= 24 {
            return 100.0
        } else if hoursSinceCreation <= 72 {
            return 70.0
        } else if hoursSinceCreation <= 168 {
            return 40.0
        } else {
            return 10.0
        }
    }
}