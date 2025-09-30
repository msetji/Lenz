//
//  ProfileViewModel.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine
import Supabase


class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var videos: [Video] = []
    @Published var totalLikes = 0

    private let userId: UUID
    private let supabase = SupabaseClientService.shared

    init(userId: UUID) {
        self.userId = userId
    }

    func loadProfile() async {
        await loadUser()
        await loadVideos()
    }

    private func loadUser() async {
        do {
            user = try await supabase.client
                .from("users")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
        } catch {
            print("Error loading user: \(error)")
        }
    }

    private func loadVideos() async {
        do {
            videos = try await supabase.client
                .from("videos")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value

            totalLikes = videos.reduce(0) { $0 + $1.likesCount }
        } catch {
            print("Error loading videos: \(error)")
        }
    }
}