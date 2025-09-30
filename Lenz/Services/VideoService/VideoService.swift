//
//  VideoService.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine
import Supabase
import Storage


class VideoService: ObservableObject {
    private let supabase: SupabaseClientService

    init(supabase: SupabaseClientService = .shared) {
        self.supabase = supabase
    }

    func uploadVideo(data: Data, location: Location, userId: UUID) async throws -> Video {
        let videoId = UUID()
        let fileName = "\(videoId.uuidString).mp4"

        let uploadResponse = try await supabase.client.storage
            .from("videos")
            .upload(
                path: fileName,
                file: data,
                options: FileOptions(contentType: "video/mp4")
            )

        let publicURL = try supabase.client.storage
            .from("videos")
            .getPublicURL(path: uploadResponse.path)

        struct VideoInsert: Encodable {
            let id: String
            let user_id: String
            let video_url: String
            let location: LocationData
            let likes_count: Int
            let comments_count: Int
            let created_at: String

            struct LocationData: Encodable {
                let city: String
                let region: String
                let country: String
                let latitude: Double
                let longitude: Double
            }
        }

        let videoInsert = VideoInsert(
            id: videoId.uuidString,
            user_id: userId.uuidString,
            video_url: publicURL.absoluteString,
            location: VideoInsert.LocationData(
                city: location.city,
                region: location.region,
                country: location.country,
                latitude: location.latitude,
                longitude: location.longitude
            ),
            likes_count: 0,
            comments_count: 0,
            created_at: ISO8601DateFormatter().string(from: Date())
        )

        let video: Video = try await supabase.client
            .from("videos")
            .insert(videoInsert)
            .select()
            .single()
            .execute()
            .value

        return video
    }

    func fetchVideos(forCity city: String) async throws -> [Video] {
        let videos: [Video] = try await supabase.client
            .from("videos")
            .select()
            .eq("location->>city", value: city)
            .order("created_at", ascending: false)
            .execute()
            .value

        return videos
    }

    func fetchVideosNearLocation(_ location: Location, radius: Double = 50.0) async throws -> [Video] {
        let videos: [Video] = try await supabase.client
            .from("videos")
            .select()
            .execute()
            .value

        return videos.filter { video in
            let distance = self.distance(from: location.coordinate, to: video.location.coordinate)
            return distance <= radius
        }
    }

    func likeVideo(_ videoId: UUID, userId: UUID) async throws {
        let likeData: [String: String] = [
            "id": UUID().uuidString,
            "video_id": videoId.uuidString,
            "user_id": userId.uuidString,
            "created_at": ISO8601DateFormatter().string(from: Date())
        ]

        try await supabase.client
            .from("likes")
            .insert(likeData)
            .execute()
    }

    func unlikeVideo(_ videoId: UUID, userId: UUID) async throws {
        try await supabase.client
            .from("likes")
            .delete()
            .eq("video_id", value: videoId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }

    func addComment(_ text: String, videoId: UUID, userId: UUID) async throws -> Comment {
        let commentData: [String: String] = [
            "id": UUID().uuidString,
            "video_id": videoId.uuidString,
            "user_id": userId.uuidString,
            "text": text,
            "created_at": ISO8601DateFormatter().string(from: Date())
        ]

        let comment: Comment = try await supabase.client
            .from("comments")
            .insert(commentData)
            .select()
            .single()
            .execute()
            .value

        return comment
    }

    func fetchComments(forVideo videoId: UUID) async throws -> [Comment] {
        let comments: [Comment] = try await supabase.client
            .from("comments")
            .select()
            .eq("video_id", value: videoId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return comments
    }

    private func distance(from coord1: CLLocationCoordinate2D, to coord2: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        return location1.distance(from: location2) / 1000.0
    }
}

import CoreLocation