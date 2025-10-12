//
//  CommentsView.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import SwiftUI

struct CommentsView: View {
    let videoId: UUID
    @StateObject private var viewModel: CommentsViewModel
    @Environment(\.dismiss) var dismiss

    init(videoId: UUID) {
        self.videoId = videoId
        _viewModel = StateObject(wrappedValue: CommentsViewModel(videoId: videoId))
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.comments.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "message")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No comments yet")
                            .font(.headline)
                        Text("Be the first to comment!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(viewModel.comments) { comment in
                                CommentRow(comment: comment)
                            }
                        }
                        .padding()
                    }
                }

                Divider()

                HStack {
                    TextField("Add a comment...", text: $viewModel.commentText)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        Task {
                            await viewModel.addComment()
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.commentText.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.loadComments()
        }
    }
}

struct CommentRow: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(comment.user?.displayName.prefix(1).uppercased() ?? "?")
                        .font(.headline)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(comment.user?.username ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(comment.text)
                    .font(.body)

                Text(comment.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}