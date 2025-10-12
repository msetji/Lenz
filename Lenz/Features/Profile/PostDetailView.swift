//
//  PostDetailView.swift
//  Lenz
//
//  Created by Michael Setji on 10/12/25.
//

import SwiftUI
import AVKit

struct PostDetailView: View {
    let video: Video
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: VideoPlayerViewModel

    init(video: Video) {
        self.video = video
        _viewModel = StateObject(wrappedValue: VideoPlayerViewModel(video: video))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Media content
                    if video.mediaType == .photo {
                        // Photo slideshow
                        if let mediaUrls = video.mediaUrls, !mediaUrls.isEmpty {
                            TabView {
                                ForEach(Array(mediaUrls.enumerated()), id: \.offset) { index, urlString in
                                    if let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                            .tabViewStyle(.page)
                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                            .frame(maxHeight: .infinity)
                        }
                    } else {
                        // Video player
                        if let player = viewModel.player {
                            VideoPlayer(player: player)
                                .frame(maxHeight: .infinity)
                                .onAppear {
                                    player.play()
                                }
                                .onDisappear {
                                    player.pause()
                                }
                        } else {
                            ProgressView()
                                .frame(maxHeight: .infinity)
                        }
                    }

                    // Post info
                    VStack(alignment: .leading, spacing: 12) {
                        // User info
                        HStack(spacing: 12) {
                            if let user = video.user {
                                if let avatarURL = user.avatarURL,
                                   let url = URL(string: avatarURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(user.displayName.prefix(1).uppercased())
                                                .foregroundColor(.white)
                                        )
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.displayName)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(video.location.city + ", " + video.location.country)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }

                            Spacer()
                        }
                        .padding()

                        // Stats
                        HStack(spacing: 24) {
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("\(video.likesCount)")
                                    .foregroundColor(.white)
                            }

                            HStack(spacing: 4) {
                                Image(systemName: "bubble.right.fill")
                                    .foregroundColor(.blue)
                                Text("\(video.commentsCount)")
                                    .foregroundColor(.white)
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color.black.opacity(0.7))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}
