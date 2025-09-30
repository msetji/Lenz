//
//  FeedView.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import SwiftUI
import AVKit

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var locationService: LocationService

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading videos...")
            } else if viewModel.videos.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No videos in your area yet")
                        .font(.headline)
                    Text("Be the first to post!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            } else {
                TabView(selection: $viewModel.currentVideoIndex) {
                    ForEach(Array(viewModel.videos.enumerated()), id: \.element.id) { index, video in
                        VideoPlayerView(video: video)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
            }
        }
        .task {
            await viewModel.loadVideos(locationService: locationService)
        }
        .refreshable {
            await viewModel.loadVideos(locationService: locationService)
        }
    }
}

struct VideoPlayerView: View {
    let video: Video
    @StateObject private var viewModel: VideoPlayerViewModel

    init(video: Video) {
        self.video = video
        _viewModel = StateObject(wrappedValue: VideoPlayerViewModel(video: video))
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("@\(video.user?.username ?? "Unknown")")
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text("\(video.location.city), \(video.location.region)")
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    VStack(spacing: 20) {
                        Button {
                            Task {
                                await viewModel.toggleLike()
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(viewModel.isLiked ? .red : .white)
                                Text("\(viewModel.likesCount)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }

                        Button {
                            viewModel.showComments = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "message")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("\(video.commentsCount)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.player?.play()
        }
        .onDisappear {
            viewModel.player?.pause()
        }
        .sheet(isPresented: $viewModel.showComments) {
            CommentsView(videoId: video.id)
        }
    }
}