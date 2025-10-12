//
//  ProfileViewModel.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine
import Supabase
import PostgREST

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var videos: [Video] = []
    @Published var totalLikes = 0
    @Published var isLoading = false

    private let userId: UUID
    private let supabase = SupabaseClientService.shared
    private var loadTask: Task<Void, Never>?

    init(userId: UUID) {
        self.userId = userId
    }

    func loadProfile() async {
        // Cancel any existing load task
        loadTask?.cancel()

        // Don't start a new load if already loading
        guard !isLoading else { return }

        isLoading = true

        loadTask = Task {
            await loadUser()
            if !Task.isCancelled {
                await loadVideos()
            }
            isLoading = false
        }

        await loadTask?.value
    }

    private func loadUser() async {
        guard !Task.isCancelled else { return }

        do {
            let users: [User] = try await supabase.client
                .from("users")
                .select()
                .eq("id", value: userId.uuidString)
                .execute()
                .value

            guard !Task.isCancelled else { return }
            user = users.first

            if user == nil {
                print("No user found with id: \(userId)")
            }
        } catch {
            if !Task.isCancelled {
                print("Error loading user: \(error)")
            }
        }
    }

    private func loadVideos() async {
        guard !Task.isCancelled else { return }

        do {
            videos = try await supabase.client
                .from("videos")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value

            guard !Task.isCancelled else { return }
            totalLikes = videos.reduce(0) { $0 + $1.likesCount }
        } catch {
            if !Task.isCancelled {
                print("Error loading videos: \(error)")
            }
        }
    }
}