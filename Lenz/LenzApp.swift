//
//  LenzApp.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import SwiftUI
import Supabase
import Auth

@main
struct LenzApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    if let user = authService.currentUser, !user.isProfileComplete {
                        ProfileSetupView()
                    } else {
                        MainTabView()
                    }
                } else {
                    AuthenticationView()
                }
            }
            .environmentObject(authService)
            .environmentObject(locationService)
            .onAppear {
                locationService.requestLocationPermission()
            }
            .onOpenURL { url in
                Task {
                    do {
                        try await SupabaseClientService.shared.client.auth.session(from: url)
                    } catch {
                        print("Failed to handle auth callback: \(error)")
                    }
                }
            }
        }
    }
}
