//
//  Video.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation

enum MediaType: String, Codable {
    case video
    case photo
}

struct Video: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let videoURL: String?
    let thumbnailURL: String?
    let mediaType: MediaType
    let mediaUrls: [String]?
    let location: Location
    let likesCount: Int
    let commentsCount: Int
    let createdAt: Date

    var user: User?

    // Computed property for display
    var primaryMediaURL: String {
        if mediaType == .photo {
            return mediaUrls?.first ?? ""
        } else {
            return videoURL ?? ""
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case videoURL = "video_url"
        case thumbnailURL = "thumbnail_url"
        case mediaType = "media_type"
        case mediaUrls = "media_urls"
        case location
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case createdAt = "created_at"
    }
}