//
//  PreferenceClientTests.swift
//
//
//  Created by Michael Miller on 7/22/24.
//

import XCTest
@testable import Courier_iOS

class PreferenceClientTests: XCTestCase {
    
    func testGetPreferences() async throws {

        let client = try await ClientBuilder.build()
        
        let preferences = try await client.preferences.getUserPreferences()
        
        XCTAssertTrue(!preferences.items.isEmpty)

    }
    
    func testGetTopic() async throws {

        let client = try await ClientBuilder.build()
        
        let topic = try await client.preferences.getUserPreferenceTopic(
            topicId: Env.COURIER_PREFERENCE_TOPIC_ID
        )
        
        XCTAssertTrue(topic.topicId == Env.COURIER_PREFERENCE_TOPIC_ID)

    }
    
    func testUpdateTopic() async throws {

        let client = try await ClientBuilder.build()
        
        try await client.preferences.putUserPreferenceTopic(
            topicId: Env.COURIER_PREFERENCE_TOPIC_ID,
            status: .optedIn,
            hasCustomRouting: true,
            customRouting: [.push]
        )

    }
    
}
