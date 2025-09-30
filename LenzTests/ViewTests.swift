//
//  ViewTests.swift
//  LenzTests
//
//  Created by Michael Setji on 9/30/25.
//

import XCTest
import SwiftUI
@testable import Lenz

@MainActor
final class ViewTests: XCTestCase {
    func testFeedView_Initialization() {
        let view = FeedView()
        XCTAssertNotNil(view)
    }

    func testMapView_Initialization() {
        let view = MapView()
        XCTAssertNotNil(view)
    }

    func testSearchView_Initialization() {
        let view = SearchView()
        XCTAssertNotNil(view)
    }

    func testUploadView_Initialization() {
        let view = UploadView()
        XCTAssertNotNil(view)
    }

    func testProfileView_Initialization() {
        let userId = UUID()
        let view = ProfileView(userId: userId)
        XCTAssertNotNil(view)
    }

    func testMainTabView_Initialization() {
        let view = MainTabView()
        XCTAssertNotNil(view)
    }

    func testAuthenticationView_Initialization() {
        let view = AuthenticationView()
        XCTAssertNotNil(view)
    }
}