//
//  VideoPlayerViewModel.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine
import Supabase
import AVKit


class VideoPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isLiked = false
    @Published var likesCount: Int
    @Published var showComments = false

    private let video: Video
    private let videoService = VideoService()

    init(video: Video) {
        self.video = video
        self.likesCount = video.likesCount

        // Only create player for videos, not photos
        if video.mediaType == .video, let videoURL = video.videoURL, let url = URL(string: videoURL) {
            self.player = AVPlayer(url: url)
            self.player?.actionAtItemEnd = .none

            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem,
                queue: .main
            ) { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }
        }
    }

    func toggleLike() async {
        guard let userId = SupabaseClientService.shared.client.auth.currentUser?.id else {
            return
        }

        do {
            if isLiked {
                try await videoService.unlikeVideo(video.id, userId: userId)
                likesCount -= 1
                isLiked = false
            } else {
                try await videoService.likeVideo(video.id, userId: userId)
                likesCount += 1
                isLiked = true
            }
        } catch {
            print("Error toggling like: \(error)")
        }
    }
}