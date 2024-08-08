//
//  TrackingClientTests.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
//

import XCTest
@testable import Courier_iOS

class TrackingClientTests: XCTestCase {
    
    private let trackingUrl = "https://af6303be-0e1e-40b5-bb80-e1d9299cccff.ct0.app/t/tzgspbr4jcmcy1qkhw96m0034bvy"
    
    func testWithDefaultClient() async throws {

        let client = CourierClient.default
        
        try await client.tracking.postTrackingUrl(
            url: trackingUrl,
            event: .delivered
        )

    }
    
    func testDelivered() async throws {

        let client = try await ClientBuilder.build()
        
        try await client.tracking.postTrackingUrl(
            url: trackingUrl,
            event: .delivered
        )

    }
    
    func testClicked() async throws {

        let client = try await ClientBuilder.build()
        
        try await client.tracking.postTrackingUrl(
            url: trackingUrl,
            event: .clicked
        )

    }
    
}
