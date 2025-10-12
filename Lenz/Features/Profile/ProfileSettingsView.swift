//
//  ProfileSettingsView.swift
//  Lenz
//
//  Created by Michael Setji on 10/9/25.
//

import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    @State private var showingEditProfile = false
    @State private var showingSignOutAlert = false
    let user: User?

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        showingEditProfile = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("Edit Profile")
                                .foregroundColor(.primary)
                        }
                    }
                }

                Section {
                    Button {
                        showingSignOutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 30)
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            if let user = user {
                ProfileEditView(user: user)
            }
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    try? await authService.signOut()
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}
