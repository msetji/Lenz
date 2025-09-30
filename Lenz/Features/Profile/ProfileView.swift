//
//  ProfileView.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import SwiftUI

struct ProfileView: View {
    let userId: UUID
    @StateObject private var viewModel: ProfileViewModel
    @EnvironmentObject var authService: AuthService

    init(userId: UUID) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(viewModel.user?.username.prefix(1).uppercased() ?? "?")
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                        )

                    VStack(spacing: 4) {
                        Text(viewModel.user?.username ?? "Loading...")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(viewModel.user?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    HStack(spacing: 40) {
                        VStack(spacing: 4) {
                            Text("\(viewModel.videos.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Videos")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        VStack(spacing: 4) {
                            Text("\(viewModel.totalLikes)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Likes")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    if userId == authService.currentUser?.id {
                        Button {
                            Task {
                                try? await authService.signOut()
                            }
                        } label: {
                            Text("Sign Out")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()

                Divider()

                if viewModel.videos.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No videos yet")
                            .font(.headline)
                    }
                    .padding(.top, 40)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 2) {
                        ForEach(viewModel.videos) { video in
                            VideoThumbnail(video: video)
                        }
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadProfile()
        }
    }
}