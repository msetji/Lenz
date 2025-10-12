//
//  ProfileSetupViewModel.swift
//  Lenz
//
//  Created by Michael Setji on 10/9/25.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine
import Supabase
import PostgREST
import Storage

@MainActor
class ProfileSetupViewModel: ObservableObject {
    @Published var username = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var profileImage: UIImage?
    @Published var usernameError: String?
    @Published var isCheckingUsername = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var usernameCheckTask: Task<Void, Never>?
    private let supabase = SupabaseClientService.shared

    var canSubmit: Bool {
        !username.isEmpty &&
        usernameError == nil &&
        !isCheckingUsername &&
        username.count >= 3
    }

    init() {
        // Watch for username changes and validate
        $username
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.validateUsername()
                }
            }
            .store(in: &cancellables)

        // Watch for photo selection
        $selectedPhoto
            .sink { [weak self] item in
                Task { @MainActor in
                    await self?.loadImage(from: item)
                }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    func validateUsername() async {
        guard !username.isEmpty else {
            usernameError = nil
            return
        }

        // Cancel previous check
        usernameCheckTask?.cancel()

        // Basic validation
        if username.count < 3 {
            usernameError = "Username must be at least 3 characters"
            return
        }

        if username.count > 20 {
            usernameError = "Username must be less than 20 characters"
            return
        }

        let validCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        if username.unicodeScalars.contains(where: { !validCharacters.contains($0) }) {
            usernameError = "Username can only contain letters, numbers, and underscores"
            return
        }

        // Check availability
        isCheckingUsername = true
        usernameError = nil

        usernameCheckTask = Task {
            do {
                let count: Int = try await supabase.client
                    .from("users")
                    .select("id", head: true, count: .exact)
                    .eq("username", value: username.lowercased())
                    .execute()
                    .count ?? 0

                if !Task.isCancelled {
                    if count > 0 {
                        usernameError = "Username is already taken"
                    } else {
                        usernameError = nil
                    }
                    isCheckingUsername = false
                }
            } catch {
                if !Task.isCancelled {
                    usernameError = "Failed to check username availability"
                    isCheckingUsername = false
                }
            }
        }
    }

    func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                profileImage = image
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }

    func completeProfile(authService: AuthService) async {
        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil

        do {
            var avatarURL: String?

            // Upload profile picture if selected
            if let image = profileImage {
                avatarURL = try await uploadProfilePicture(image, userId: authService.currentUser?.id ?? UUID())
            }

            // Update user profile
            struct UserUpdate: Encodable {
                let username: String
                let avatar_url: String?
            }

            let update = UserUpdate(
                username: username.lowercased(),
                avatar_url: avatarURL
            )

            try await supabase.client
                .from("users")
                .update(update)
                .eq("id", value: authService.currentUser?.id.uuidString ?? "")
                .execute()

            // Refresh user data
            await authService.checkSession()

            isLoading = false
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func uploadProfilePicture(_ image: UIImage, userId: UUID) async throws -> String {
        // Resize image to reduce upload size
        let resizedImage = image.resized(to: CGSize(width: 400, height: 400))
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ProfileSetup", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])
        }

        let fileName = "\(userId.uuidString)-\(Date().timeIntervalSince1970).jpg"
        let filePath = "avatars/\(fileName)"

        try await supabase.client.storage
            .from("profiles")
            .upload(filePath, data: imageData, options: .init(contentType: "image/jpeg"))

        // Get public URL
        let publicURL = try supabase.client.storage
            .from("profiles")
            .getPublicURL(path: filePath)

        return publicURL.absoluteString
    }
}

// Image resizing extension
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
