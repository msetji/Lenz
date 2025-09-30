//
//  AuthenticationView.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "video.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("Lenz")
                    .font(.system(size: 50, weight: .bold))

                Text("Discover videos from your city")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 16) {
                Button {
                    Task {
                        await signInWithGoogle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)

                        Text("Continue with Google")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
        .background(Color(.systemBackground))
    }

    private func signInWithGoogle() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signInWithGoogle()
        } catch {
            print("Sign in error: \(error)")
        }
    }
}