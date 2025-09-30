//
//  SupabaseClientService.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine
import Supabase

final class SupabaseClientService: ObservableObject {
    static let shared = SupabaseClientService()

    let client: SupabaseClient

    private init() {
        guard let url = URL(string: "SUPABASE_URL_PLACEHOLDER") else {
            fatalError("Invalid Supabase URL")
        }

        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: "SUPABASE_ANON_KEY_PLACEHOLDER"
        )
    }
}