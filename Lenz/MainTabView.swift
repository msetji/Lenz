//
//  MainTabView.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab = 0
    @State private var showUpload = false
    @State private var profileRefreshTrigger = UUID()

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "play.rectangle.fill")
                }
                .tag(0)

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(1)

            Color.clear
                .tabItem {
                    Label("Upload", systemImage: "plus.circle.fill")
                }
                .tag(2)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(3)

            if let userId = authService.currentUser?.id {
                ProfileView(userId: userId, refreshTrigger: profileRefreshTrigger)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(4)
            } else {
                // Fallback profile view when user data is missing
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("Profile Not Loaded")
                        .font(.headline)

                    Text("Unable to load user data")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Button {
                        Task {
                            try? await authService.signOut()
                        }
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                }
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 2 {
                showUpload = true
                selectedTab = oldValue
            }
        }
        .sheet(isPresented: $showUpload, onDismiss: {
            // Refresh profile after upload sheet closes
            profileRefreshTrigger = UUID()
        }) {
            UploadViewNew()
        }
    }
}