//
//  Like.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation

struct Like: Codable, Identifiable {
    let id: UUID
    let videoId: UUID
    let userId: UUID
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case videoId = "video_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}