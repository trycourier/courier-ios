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
    
    func testTrackMessage() async throws {
        
        let message: [AnyHashable: Any] = [
            "trackingUrl": trackingUrl
        ]
        
        await message.trackMessage(
            event: .delivered
        )

    }
    
    func testTrackMessageWithDictionary() async throws {
        let trackingUrl = "your_tracking_url_here"
        
        let message: NSDictionary = [
            "trackingUrl": trackingUrl
        ]
        
        try await withCheckedThrowingContinuation { continuation in
            message.trackMessage(event: .delivered) { error in
                if let error = error {
                    // This will likely get called because the url is fake.. At least the request works
                    print("Failed to track the message: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
    }
    
}
