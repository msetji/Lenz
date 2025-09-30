//
//  Comment.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation

struct Comment: Codable, Identifiable {
    let id: UUID
    let videoId: UUID
    let userId: UUID
    let text: String
    let createdAt: Date

    var user: User?

    enum CodingKeys: String, CodingKey {
        case id
        case videoId = "video_id"
        case userId = "user_id"
        case text
        case createdAt = "created_at"
    }
}