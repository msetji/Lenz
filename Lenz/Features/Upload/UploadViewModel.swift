//
//  UploadViewModel.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI
import AVFoundation


class UploadViewModel: ObservableObject {
    @Published var selectedVideo: PhotosPickerItem?
    @Published var videoThumbnail: UIImage?
    @Published var isUploading = false
    @Published var showCamera = false
    @Published var showError = false
    @Published var errorMessage = ""

    private var videoData: Data?
    private let videoService = VideoService()

    func loadVideo() async {
        guard let selectedVideo = selectedVideo else { return }

        do {
            if let data = try await selectedVideo.loadTransferable(type: Data.self) {
                videoData = data
                videoThumbnail = await generateThumbnail(from: data)
            }
        } catch {
            print("Error loading video: \(error)")
        }
    }

    func processVideoURL(_ url: URL) {
        do {
            videoData = try Data(contentsOf: url)
            Task {
                videoThumbnail = await generateThumbnail(from: url)
            }
        } catch {
            print("Error processing video URL: \(error)")
        }
    }

    func uploadVideo(locationService: LocationService) async {
        guard let videoData = videoData,
              let currentLocation = locationService.currentLocation,
              let userId = SupabaseClientService.shared.client.auth.currentUser?.id else {
            showError(message: "Missing video data, location, or user authentication")
            return
        }

        isUploading = true
        defer { isUploading = false }

        do {
            let location = try await locationService.geocodeLocation(currentLocation)
            _ = try await videoService.uploadVideo(data: videoData, location: location, userId: userId)
        } catch {
            showError(message: "Failed to upload video: \(error.localizedDescription)")
        }
    }

    private func generateThumbnail(from data: Data) async -> UIImage? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")

        do {
            try data.write(to: tempURL)
            return await generateThumbnail(from: tempURL)
        } catch {
            print("Error writing video data: \(error)")
            return nil
        }
    }

    private func generateThumbnail(from url: URL) async -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}