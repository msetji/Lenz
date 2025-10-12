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
        // TODO: Replace these with your actual Supabase credentials
        // You can get these from: https://supabase.com/dashboard → Your Project → Settings → API
        let supabaseURL = "https://vlnjufgnjoluvuzfzhju.supabase.co"
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZsbmp1Zmduam9sdXZ1emZ6aGp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyNDM5NzEsImV4cCI6MjA3NDgxOTk3MX0.6rKgxQ2GdfxRDARmSxmE5c9yMDNSZjF8-D_P6pmioSY"

        guard let url = URL(string: supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }

        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    redirectToURL: URL(string: "com.msetji.lenz://auth-callback")
                )
            )
        )
    }
}