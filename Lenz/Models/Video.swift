//
//  Video.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation

struct Video: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let videoURL: String
    let thumbnailURL: String?
    let location: Location
    let likesCount: Int
    let commentsCount: Int
    let createdAt: Date

    var user: User?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case videoURL = "video_url"
        case thumbnailURL = "thumbnail_url"
        case location
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case createdAt = "created_at"
    }
}