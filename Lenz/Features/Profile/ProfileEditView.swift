//
//  ProfileEditView.swift
//  Lenz
//
//  Created by Michael Setji on 10/9/25.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: ProfileEditViewModel

    init(user: User) {
        _viewModel = StateObject(wrappedValue: ProfileEditViewModel(user: user))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Picture
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                            ProfileImageView(viewModel: viewModel)
                        }

                        if viewModel.selectedPhoto != nil {
                            Button("Remove Photo") {
                                viewModel.selectedPhoto = nil
                                viewModel.profileImage = nil
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.top)

                    // Username Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.headline)

                        TextField("Username", text: $viewModel.username)
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
                        } else if viewModel.username != viewModel.user.username && !viewModel.username.isEmpty && viewModel.usernameError == nil {
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

                    // Email (read-only)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)

                        Text(viewModel.user.email)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.saveProfile(authService: authService)
                            dismiss()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!viewModel.canSave || viewModel.isLoading)
                }
            }
        }
    }
}

// Helper view to avoid main actor isolation issues
struct ProfileImageView: View {
    @ObservedObject var viewModel: ProfileEditViewModel

    var body: some View {
        ZStack {
            if let image = viewModel.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            } else if let avatarURL = viewModel.user.avatarURL,
                      let url = URL(string: avatarURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                        )
                }
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
