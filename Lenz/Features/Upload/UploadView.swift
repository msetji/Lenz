//
//  UploadView.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import SwiftUI
import PhotosUI

struct UploadView: View {
    @StateObject private var viewModel = UploadViewModel()
    @EnvironmentObject var locationService: LocationService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
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

                VStack(spacing: 16) {
                    PhotosPicker(selection: $viewModel.selectedVideo, matching: .videos) {
                        Label("Select Video", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button {
                        viewModel.showCamera = true
                    } label: {
                        Label("Record Video", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    if viewModel.selectedVideo != nil {
                        Button {
                            Task {
                                await viewModel.uploadVideo(locationService: locationService)
                                dismiss()
                            }
                        } label: {
                            if viewModel.isUploading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
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
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Upload Video")
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
        .sheet(isPresented: $viewModel.showCamera) {
            CameraView(onVideoRecorded: { url in
                viewModel.processVideoURL(url)
            })
        }
        .onChange(of: viewModel.selectedVideo) {
            Task {
                await viewModel.loadVideo()
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    let onVideoRecorded: (URL) -> Void
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.videoMaximumDuration = 60
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.onVideoRecorded(url)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}