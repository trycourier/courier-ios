//
//  PreferenceClientTests.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
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
            customRouting: [.inbox]
        )

    }
    
    func testInboxMessageOptedOut() async throws {

        let client = try await ClientBuilder.build()
        
        try await client.preferences.putUserPreferenceTopic(
            topicId: Env.COURIER_PREFERENCE_TOPIC_ID,
            status: .optedOut,
            hasCustomRouting: false,
            customRouting: []
        )
        
        try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
        
        let messageId = try await ExampleServer.sendTemplateTest(
            authKey: Env.COURIER_AUTH_KEY,
            userId: client.options.userId,
            templateId: Env.COURIER_MESSAGE_TEMPLATE_ID
        )
        
        try await Task.sleep(nanoseconds: 20 * 1_000_000_000)
        
        let res = try await client.inbox.getMessages()
        
        let message = res.data?.messages?.nodes?.first(where: { $0.messageId == messageId })
        
        XCTAssertTrue(message == nil)

    }
    
}
