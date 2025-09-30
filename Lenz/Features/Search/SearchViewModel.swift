//
//  SearchViewModel.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine


class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var users: [User] = []
    @Published var isLoading = false

    private let supabase = SupabaseClientService.shared

    func search() async {
        guard !searchQuery.isEmpty else {
            users = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            users = try await supabase.client
                .from("users")
                .select()
                .ilike("username", pattern: "%\(searchQuery)%")
                .execute()
                .value
        } catch {
            print("Error searching users: \(error)")
        }
    }
}