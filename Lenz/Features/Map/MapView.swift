//
//  MapView.swift
//  Lenz
//
//  Created by Michael Setji on 9/30/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var selectedCity: String?

    var body: some View {
        ZStack {
            Map(position: $viewModel.cameraPosition, selection: $selectedCity) {
                ForEach(viewModel.cityAnnotations) { annotation in
                    Annotation(annotation.city, coordinate: annotation.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 30, height: 30)

                            Text("\(annotation.videoCount)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            selectedCity = annotation.city
                        }
                    }
                }

                UserAnnotation()
            }
            .mapStyle(.standard)
            .ignoresSafeArea()

            VStack {
                Spacer()

                if let city = selectedCity {
                    CityVideosSheet(city: city, isPresented: .init(
                        get: { selectedCity != nil },
                        set: { if !$0 { selectedCity = nil } }
                    ))
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .task {
            await viewModel.loadCityAnnotations()
        }
    }
}

struct CityAnnotation: Identifiable {
    let id = UUID()
    let city: String
    let coordinate: CLLocationCoordinate2D
    let videoCount: Int
}

struct CityVideosSheet: View {
    let city: String
    @Binding var isPresented: Bool
    @StateObject private var viewModel: CityVideosViewModel

    init(city: String, isPresented: Binding<Bool>) {
        self.city = city
        self._isPresented = isPresented
        _viewModel = StateObject(wrappedValue: CityVideosViewModel(city: city))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(city)
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemBackground))

            if viewModel.videos.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No videos in \(city)")
                        .font(.headline)
                }
                .frame(maxHeight: 200)
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 2) {
                        ForEach(viewModel.videos) { video in
                            VideoThumbnail(video: video)
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
        .task {
            await viewModel.loadVideos()
        }
    }
}

struct VideoThumbnail: View {
    let video: Video
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            ZStack {
                // Thumbnail image
                if let thumbnailURL = video.thumbnailURL ?? video.mediaUrls?.first,
                   let url = URL(string: thumbnailURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .aspectRatio(9/16, contentMode: .fill)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(9/16, contentMode: .fit)
                }

                // Media type indicator
                if video.mediaType == .video {
                    Image(systemName: "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                } else if let count = video.mediaUrls?.count, count > 1 {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "square.stack.fill")
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $showDetail) {
            PostDetailView(video: video)
        }
    }
}