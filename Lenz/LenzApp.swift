//
//  LenzApp.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import SwiftUI

@main
struct LenzApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    MainTabView()
                } else {
                    AuthenticationView()
                }
            }
            .environmentObject(authService)
            .environmentObject(locationService)
            .onAppear {
                locationService.requestLocationPermission()
            }
        }
    }
}
