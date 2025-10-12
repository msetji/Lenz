//
//  ProfileView.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import SwiftUI

struct ProfileView: View {
    let userId: UUID
    let refreshTrigger: UUID?
    @StateObject private var viewModel: ProfileViewModel
    @EnvironmentObject var authService: AuthService
    @State private var showingSettings = false

    init(userId: UUID, refreshTrigger: UUID? = nil) {
        self.userId = userId
        self.refreshTrigger = refreshTrigger
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                VStack(spacing: 16) {
                    // Profile Picture
                    if let avatarURL = viewModel.user?.avatarURL,
                       let url = URL(string: avatarURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                )
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(viewModel.user?.displayName.prefix(1).uppercased() ?? "?")
                                    .font(.system(size: 40))
                                    .fontWeight(.bold)
                            )
                    }

                    VStack(spacing: 4) {
                        Text(viewModel.user?.displayName ?? "Loading...")
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

                }
                .padding()

                Divider()

                if viewModel.isLoading && viewModel.videos.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading posts...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                } else if viewModel.videos.isEmpty {
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
            .toolbar {
                if userId == authService.currentUser?.id {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                ProfileSettingsView(user: viewModel.user)
            }
            .task(id: refreshTrigger) {
                await viewModel.loadProfile()
            }
            .refreshable {
                await viewModel.loadProfile()
            }
        }
    }
}