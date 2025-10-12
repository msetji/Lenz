//
//  UploadViewNew.swift
//  Lenz
//
//  Created by Michael Setji on 10/9/25.
//

import SwiftUI
import PhotosUI

struct UploadViewNew: View {
    @StateObject private var viewModel = UploadViewModelNew()
    @EnvironmentObject var locationService: LocationService
    @Environment(\.dismiss) var dismiss
    @State private var uploadType: UploadType = .video

    enum UploadType {
        case video
        case photos
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Upload type picker
                Picker("Upload Type", selection: $uploadType) {
                    Text("Video").tag(UploadType.video)
                    Text("Photos").tag(UploadType.photos)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Preview
                if uploadType == .photos {
                    // Photos slideshow preview
                    if !viewModel.selectedPhotos.isEmpty {
                        TabView {
                            ForEach(Array(viewModel.selectedPhotos.enumerated()), id: \.offset) { index, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 400)
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(height: 400)
                        .cornerRadius(12)

                        Text("\(viewModel.selectedPhotos.count) photo(s) selected")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxHeight: 300)
                            .overlay(
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                            )
                            .cornerRadius(12)
                    }
                } else {
                    // Video preview
                    if let thumbnail = viewModel.videoThumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(9/16, contentMode: .fit)
                            .frame(maxHeight: 300)
                            .overlay(
                                Image(systemName: "video.badge.plus")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                            )
                            .cornerRadius(12)
                    }
                }

                // Action buttons
                VStack(spacing: 16) {
                    if uploadType == .photos {
                        PhotosPicker(selection: $viewModel.selectedPhotoItems,
                                   maxSelectionCount: 10,
                                   matching: .images) {
                            Label("Select Photos (up to 10)", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        if !viewModel.selectedPhotos.isEmpty {
                            Button {
                                Task {
                                    await viewModel.uploadPhotos(locationService: locationService)
                                    if viewModel.uploadSuccess {
                                        dismiss()
                                    }
                                }
                            } label: {
                                if viewModel.isUploading {
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .tint(.white)
                                        Text("Uploading...")
                                    }
                                } else {
                                    Text("Upload Photos")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(viewModel.isUploading)
                        }
                    } else {
                        PhotosPicker(selection: $viewModel.selectedVideo, matching: .videos) {
                            Label("Select Video", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        if viewModel.selectedVideo != nil {
                            Button {
                                Task {
                                    await viewModel.uploadVideo(locationService: locationService)
                                    if viewModel.uploadSuccess {
                                        dismiss()
                                    }
                                }
                            } label: {
                                if viewModel.isUploading {
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .tint(.white)
                                        Text("Uploading...")
                                    }
                                } else {
                                    Text("Upload Video")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(viewModel.isUploading)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Upload")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Upload Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .onChange(of: viewModel.selectedVideo) {
            Task {
                await viewModel.loadVideo()
            }
        }
        .onChange(of: viewModel.selectedPhotoItems) {
            Task {
                await viewModel.loadPhotos()
            }
        }
    }
}
