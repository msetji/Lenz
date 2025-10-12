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
        try await supabase.client.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "com.msetji.lenz://auth-callback")
        )
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
            await fetchOrCreateUser(authUser: session.user)
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
    }

    @MainActor
    private func fetchOrCreateUser(authUser: Auth.User, retryCount: Int = 0) async {
        do {
            // Try to fetch existing user
            let users: [User] = try await supabase.client
                .from("users")
                .select()
                .eq("id", value: authUser.id.uuidString)
                .execute()
                .value

            if let user = users.first {
                currentUser = user
            } else if retryCount < 3 {
                // User doesn't exist yet, wait a bit and retry (trigger might still be running)
                print("User not found, retrying in 0.5 seconds... (attempt \(retryCount + 1)/3)")
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                await fetchOrCreateUser(authUser: authUser, retryCount: retryCount + 1)
            } else {
                // After retries, create user manually
                print("User not found after retries, creating manually...")
                await createUserRecord(authUser: authUser)
            }
        } catch {
            print("Error fetching user: \(error)")
            if retryCount < 3 {
                // Retry on error
                try? await Task.sleep(nanoseconds: 500_000_000)
                await fetchOrCreateUser(authUser: authUser, retryCount: retryCount + 1)
            } else {
                // After retries, try to create
                await createUserRecord(authUser: authUser)
            }
        }
    }

    @MainActor
    private func createUserRecord(authUser: Auth.User) async {
        do {
            struct NewUserRecord: Encodable {
                let id: String
                let email: String
                let created_at: String
            }

            let newUser = NewUserRecord(
                id: authUser.id.uuidString,
                email: authUser.email ?? "",
                created_at: ISO8601DateFormatter().string(from: Date())
            )

            try await supabase.client
                .from("users")
                .insert(newUser)
                .execute()

            print("User record created successfully")

            // Small delay to let the insert complete
            try? await Task.sleep(nanoseconds: 200_000_000)

            // Fetch the newly created user
            let users: [User] = try await supabase.client
                .from("users")
                .select()
                .eq("id", value: authUser.id.uuidString)
                .execute()
                .value

            currentUser = users.first
        } catch {
            print("Failed to create user record: \(error)")
        }
    }
}