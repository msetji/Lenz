//
//  User.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let username: String
    let avatarURL: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
    }
}