//
//  UploadViewModelNew.swift
//  Lenz
//
//  Created by Michael Setji on 10/9/25.
//

import Foundation
import SwiftUI
import PhotosUI
import AVFoundation
import Combine
import Supabase
import Storage

@MainActor
class UploadViewModelNew: ObservableObject {
    @Published var selectedVideo: PhotosPickerItem?
    @Published var selectedPhotoItems: [PhotosPickerItem] = []
    @Published var selectedPhotos: [UIImage] = []
    @Published var videoThumbnail: UIImage?
    @Published var isUploading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var uploadSuccess = false

    private var videoURL: URL?
    private let supabase = SupabaseClientService.shared

    // Load photos from PhotosPicker
    func loadPhotos() async {
        selectedPhotos.removeAll()

        for item in selectedPhotoItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedPhotos.append(image)
            }
        }
    }

    // Load video from PhotosPicker
    func loadVideo() async {
        guard let item = selectedVideo else { return }

        do {
            guard let movie = try await item.loadTransferable(type: VideoTransferable.self) else {
                return
            }

            videoURL = movie.url
            videoThumbnail = try await generateThumbnail(for: movie.url)
        } catch {
            print("Error loading video: \(error)")
            errorMessage = "Failed to load video"
            showError = true
        }
    }

    // Upload multiple photos as a slideshow
    func uploadPhotos(locationService: LocationService) async {
        guard !selectedPhotos.isEmpty else { return }

        // Get authenticated user ID
        guard let userId = supabase.client.auth.currentUser?.id else {
            errorMessage = "You must be signed in to upload photos"
            showError = true
            return
        }

        isUploading = true

        do {
            var uploadedURLs: [String] = []

            // Upload each photo
            for (index, photo) in selectedPhotos.enumerated() {
                let url = try await uploadPhoto(photo, index: index)
                uploadedURLs.append(url)
            }

            // Get location
            var location: Location
            if let currentLocation = locationService.currentLocation {
                location = try await locationService.geocodeLocation(currentLocation)
            } else {
                location = Location(
                    city: "Unknown",
                    region: "Unknown",
                    country: "Unknown",
                    latitude: 0,
                    longitude: 0
                )
            }

            // Create post record
            struct PhotoPost: Encodable {
                let id: String
                let user_id: String
                let media_type: String
                let media_urls: [String]
                let thumbnail_url: String
                let location: Location
                let likes_count: Int
                let comments_count: Int
                let created_at: String
            }

            let post = PhotoPost(
                id: UUID().uuidString,
                user_id: userId.uuidString,
                media_type: "photo",
                media_urls: uploadedURLs,
                thumbnail_url: uploadedURLs.first ?? "",
                location: location,
                likes_count: 0,
                comments_count: 0,
                created_at: ISO8601DateFormatter().string(from: Date())
            )

            try await supabase.client
                .from("videos")
                .insert(post)
                .execute()

            isUploading = false
            uploadSuccess = true
        } catch {
            print("Upload error: \(error)")
            errorMessage = "Failed to upload photos: \(error.localizedDescription)"
            showError = true
            isUploading = false
        }
    }

    // Upload video (existing functionality)
    func uploadVideo(locationService: LocationService) async {
        guard let videoURL = videoURL else { return }

        // Get authenticated user ID
        guard let userId = supabase.client.auth.currentUser?.id else {
            errorMessage = "You must be signed in to upload videos"
            showError = true
            return
        }

        isUploading = true

        do {
            // Upload video to storage
            let videoData = try Data(contentsOf: videoURL)
            let videoFileName = "\(UUID().uuidString).mp4"
            let videoPath = "videos/\(videoFileName)"

            try await supabase.client.storage
                .from("videos")
                .upload(videoPath, data: videoData, options: .init(contentType: "video/mp4"))

            let videoPublicURL = try supabase.client.storage
                .from("videos")
                .getPublicURL(path: videoPath)

            // Upload thumbnail
            var thumbnailURL: String?
            if let thumbnail = videoThumbnail,
               let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) {
                let thumbnailFileName = "\(UUID().uuidString).jpg"
                let thumbnailPath = "thumbnails/\(thumbnailFileName)"

                try await supabase.client.storage
                    .from("videos")
                    .upload(thumbnailPath, data: thumbnailData, options: .init(contentType: "image/jpeg"))

                let thumbURL = try supabase.client.storage
                    .from("videos")
                    .getPublicURL(path: thumbnailPath)

                thumbnailURL = thumbURL.absoluteString
            }

            // Get location
            var location: Location
            if let currentLocation = locationService.currentLocation {
                location = try await locationService.geocodeLocation(currentLocation)
            } else {
                location = Location(
                    city: "Unknown",
                    region: "Unknown",
                    country: "Unknown",
                    latitude: 0,
                    longitude: 0
                )
            }

            // Create video record
            struct VideoPost: Encodable {
                let id: String
                let user_id: String
                let video_url: String
                let thumbnail_url: String?
                let media_type: String
                let location: Location
                let likes_count: Int
                let comments_count: Int
                let created_at: String
            }

            let post = VideoPost(
                id: UUID().uuidString,
                user_id: userId.uuidString,
                video_url: videoPublicURL.absoluteString,
                thumbnail_url: thumbnailURL,
                media_type: "video",
                location: location,
                likes_count: 0,
                comments_count: 0,
                created_at: ISO8601DateFormatter().string(from: Date())
            )

            try await supabase.client
                .from("videos")
                .insert(post)
                .execute()

            isUploading = false
            uploadSuccess = true
        } catch {
            print("Upload error: \(error)")
            errorMessage = "Failed to upload video: \(error.localizedDescription)"
            showError = true
            isUploading = false
        }
    }

    // Helper: Upload single photo
    private func uploadPhoto(_ image: UIImage, index: Int) async throws -> String {
        // Resize to reasonable size
        let resized = image.resized(to: CGSize(width: 1080, height: 1920))
        guard let imageData = resized.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "Upload", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])
        }

        let fileName = "\(UUID().uuidString)-\(index).jpg"
        let filePath = "photos/\(fileName)"

        try await supabase.client.storage
            .from("videos")
            .upload(filePath, data: imageData, options: .init(contentType: "image/jpeg"))

        let publicURL = try supabase.client.storage
            .from("videos")
            .getPublicURL(path: filePath)

        return publicURL.absoluteString
    }

    // Helper: Generate video thumbnail
    private func generateThumbnail(for url: URL) async throws -> UIImage {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 60)
        let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)

        return UIImage(cgImage: cgImage)
    }
}

// Helper for video loading
struct VideoTransferable: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "\(UUID().uuidString).mov")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self(url: copy)
        }
    }
}
