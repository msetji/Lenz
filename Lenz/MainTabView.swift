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
                ProfileView(userId: userId)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(4)
            } else {
                Text("Profile")
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
        .sheet(isPresented: $showUpload) {
            UploadView()
        }
    }
}