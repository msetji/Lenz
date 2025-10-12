//
//  ProfileSetupView.swift
//  Lenz
//
//  Created by Michael Setji on 10/9/25.
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = ProfileSetupViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text("Complete Your Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Set up your username and profile picture to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

                    // Profile Picture
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                            ProfileSetupImageView(viewModel: viewModel)
                        }

                        Text("Add Profile Photo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Username Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.headline)

                        TextField("Choose a username", text: $viewModel.username)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()

                        if let error = viewModel.usernameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if viewModel.isCheckingUsername {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Checking availability...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else if !viewModel.username.isEmpty && viewModel.usernameError == nil {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Username available")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Complete Profile Button
                    Button {
                        Task {
                            await viewModel.completeProfile(authService: authService)
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text("Complete Profile")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canSubmit ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.canSubmit || viewModel.isLoading)
                    .padding(.horizontal)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding()
            }
        }
    }
}

// Helper view to avoid main actor isolation issues
struct ProfileSetupImageView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel

    var body: some View {
        ZStack {
            if let image = viewModel.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    )
            }

            Circle()
                .fill(Color.blue)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                )
                .offset(x: 40, y: 40)
        }
    }
}
