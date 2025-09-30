//
//  CommentsViewModel.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine


class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var commentText = ""

    private let videoId: UUID
    private let videoService = VideoService()

    init(videoId: UUID) {
        self.videoId = videoId
    }

    func loadComments() async {
        do {
            comments = try await videoService.fetchComments(forVideo: videoId)
        } catch {
            print("Error loading comments: \(error)")
        }
    }

    func addComment() async {
        guard !commentText.isEmpty,
              let userId = SupabaseClientService.shared.client.auth.currentUser?.id else {
            return
        }

        do {
            let comment = try await videoService.addComment(commentText, videoId: videoId, userId: userId)
            comments.insert(comment, at: 0)
            commentText = ""
        } catch {
            print("Error adding comment: \(error)")
        }
    }
}