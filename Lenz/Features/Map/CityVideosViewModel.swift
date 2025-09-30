//
//  CityVideosViewModel.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import Foundation
import Combine


class CityVideosViewModel: ObservableObject {
    @Published var videos: [Video] = []

    private let city: String
    private let videoService = VideoService()

    init(city: String) {
        self.city = city
    }

    func loadVideos() async {
        do {
            videos = try await videoService.fetchVideos(forCity: city)
        } catch {
            print("Error loading videos for city: \(error)")
        }
    }
}