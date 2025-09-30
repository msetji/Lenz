//
//  AuthService.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine
import Supabase
import Auth

final class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false

    private let supabase: SupabaseClientService

    init() {
        self.supabase = SupabaseClientService.shared
        Task { @MainActor in
            await self.checkSession()
        }
    }

    @MainActor
    func signInWithGoogle() async throws {
        try await supabase.client.auth.signInWithOAuth(provider: .google)
    }

    @MainActor
    func signOut() async throws {
        try await supabase.client.auth.signOut()
        currentUser = nil
        isAuthenticated = false
    }

    @MainActor
    func checkSession() async {
        do {
            let session = try await supabase.client.auth.session
            isAuthenticated = true
            await fetchCurrentUser(userId: session.user.id)
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
    }

    @MainActor
    private func fetchCurrentUser(userId: UUID) async {
        do {
            let user: User = try await supabase.client
                .from("users")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value

            currentUser = user
        } catch {
            print("Failed to fetch current user: \(error)")
        }
    }
}