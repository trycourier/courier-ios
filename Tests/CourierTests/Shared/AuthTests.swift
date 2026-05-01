//
//  AuthTests.swift
//
//
//  Created by https://github.com/mikemilla on 7/23/24.
//

import XCTest
@testable import Courier_iOS

class AuthTests: XCTestCase {
    
    func testSignUserIn() async throws {
        let expectation = XCTestExpectation(description: "User signed in")
        
        let listener = await Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No user found")
            if userId != nil {
                expectation.fulfill()
            }
        }
        
        await Courier.shared.signIn(
            userId: Env.COURIER_USER_ID,
            accessToken: Env.COURIER_AUTH_KEY
        )
        
        let accessToken = (await Courier.shared.accessToken) == Env.COURIER_AUTH_KEY
        XCTAssertTrue(accessToken)
        
        let userId = (await Courier.shared.userId) == Env.COURIER_USER_ID
        XCTAssertTrue(userId)
        
        let clientKey = (await Courier.shared.clientKey) == nil
        XCTAssertTrue(clientKey)
        
        await Courier.shared.removeAuthenticationListener(listener)
        
        let listeners = await Courier.shared.authListeners.isEmpty
        XCTAssertTrue(listeners)
    }

    func testSignUserOut() async throws {
        let expectation = XCTestExpectation(description: "User signed out")
        
        let listener = await Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No user found")
            if userId == nil {
                expectation.fulfill()
            }
        }
        
        await Courier.shared.signOut()
        
        let missingAccessToken = await Courier.shared.accessToken == nil
        XCTAssertTrue(missingAccessToken)
        
        let missingUserId = await Courier.shared.userId == nil
        XCTAssertTrue(missingUserId)
        
        let missingClientKey = await Courier.shared.clientKey == nil
        XCTAssertTrue(missingClientKey)
        
        await Courier.shared.removeAuthenticationListener(listener)
        
        let emptyListeners = await Courier.shared.authListeners.isEmpty
        XCTAssertTrue(emptyListeners)
    }

    
    func testSingleListenerRemoval() async throws {

        let listener = await Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No user found")
        }

        await Courier.shared.removeAuthenticationListener(listener)

    }
    
    func testMultipleListenerRemoval() async throws {

        await registerAuthListeners()

        await Courier.shared.removeAllAuthenticationListeners()

    }
    
    func testListenerSpam() async throws {
        
        async let task1: () = registerAuthListeners()
        async let task2: () = registerAuthListeners()
        async let task3: () = registerAuthListeners()
        async let task4: () = registerAuthListeners()
        async let task5: () = registerAuthListeners()
        
        let _ = await (task1, task2, task3, task4, task5)
        
        await Courier.shared.removeAllAuthenticationListeners()
        
    }
    
    private func registerAuthListeners(_ numberOfListeners: Int = 10) async {
        for _ in 1...numberOfListeners {
            await Courier.shared.addAuthenticationListener { _ in }
        }
    }
    
    // MARK: - ApiUrls
    
    func testDefaultApiUrlsUseCurrentInboxHosts() {
        let urls = CourierClient.ApiUrls()
        
        XCTAssertEqual(urls.rest, "https://api.courier.com")
        XCTAssertEqual(urls.graphql, "https://api.courier.com/client/q")
        XCTAssertEqual(urls.inboxGraphql, "https://inbox.courier.com/q")
        XCTAssertEqual(urls.inboxWebSocket, "wss://realtime.courier.io")
    }
    
    func testEuApiUrlsPreset() {
        let urls = CourierClient.ApiUrls.eu
        
        XCTAssertEqual(urls.rest, "https://api.eu.courier.com")
        XCTAssertEqual(urls.graphql, "https://api.eu.courier.com/client/q")
        XCTAssertEqual(urls.inboxGraphql, "https://inbox.eu.courier.io/q")
        XCTAssertEqual(urls.inboxWebSocket, "wss://realtime.eu.courier.io")
    }
    
    func testUsPresetMatchesDefault() {
        let defaultUrls = CourierClient.ApiUrls()
        let usUrls = CourierClient.ApiUrls.us
        
        XCTAssertEqual(defaultUrls.rest, usUrls.rest)
        XCTAssertEqual(defaultUrls.graphql, usUrls.graphql)
        XCTAssertEqual(defaultUrls.inboxGraphql, usUrls.inboxGraphql)
        XCTAssertEqual(defaultUrls.inboxWebSocket, usUrls.inboxWebSocket)
    }
    
    func testCustomApiUrls() {
        let urls = CourierClient.ApiUrls(
            rest: "https://custom.api.example.com",
            graphql: "https://custom.api.example.com/client/q",
            inboxGraphql: "https://custom.inbox.example.com/q",
            inboxWebSocket: "wss://custom.realtime.example.com"
        )
        
        XCTAssertEqual(urls.rest, "https://custom.api.example.com")
        XCTAssertEqual(urls.graphql, "https://custom.api.example.com/client/q")
        XCTAssertEqual(urls.inboxGraphql, "https://custom.inbox.example.com/q")
        XCTAssertEqual(urls.inboxWebSocket, "wss://custom.realtime.example.com")
    }
    
    func testPartialCustomApiUrlsFallBackToDefaults() {
        let urls = CourierClient.ApiUrls(
            rest: "https://custom.api.example.com"
        )
        
        XCTAssertEqual(urls.rest, "https://custom.api.example.com")
        XCTAssertEqual(urls.graphql, "https://api.courier.com/client/q")
        XCTAssertEqual(urls.inboxGraphql, "https://inbox.courier.com/q")
        XCTAssertEqual(urls.inboxWebSocket, "wss://realtime.courier.io")
    }
    
    func testClientOptionsReceiveCustomApiUrls() {
        let customUrls = CourierClient.ApiUrls(
            rest: "https://custom.api.example.com",
            graphql: "https://custom.api.example.com/client/q",
            inboxGraphql: "https://custom.inbox.example.com/q",
            inboxWebSocket: "wss://custom.realtime.example.com"
        )
        
        let client = CourierClient(
            userId: "test-user",
            apiUrls: customUrls
        )
        
        XCTAssertEqual(client.options.apiUrls.rest, customUrls.rest)
        XCTAssertEqual(client.options.apiUrls.graphql, customUrls.graphql)
        XCTAssertEqual(client.options.apiUrls.inboxGraphql, customUrls.inboxGraphql)
        XCTAssertEqual(client.options.apiUrls.inboxWebSocket, customUrls.inboxWebSocket)
    }
    
    func testClientOptionsReceiveEuApiUrls() {
        let client = CourierClient(
            userId: "test-user",
            apiUrls: .eu
        )
        
        let euUrls = CourierClient.ApiUrls.eu
        XCTAssertEqual(client.options.apiUrls.rest, euUrls.rest)
        XCTAssertEqual(client.options.apiUrls.graphql, euUrls.graphql)
        XCTAssertEqual(client.options.apiUrls.inboxGraphql, euUrls.inboxGraphql)
        XCTAssertEqual(client.options.apiUrls.inboxWebSocket, euUrls.inboxWebSocket)
    }
    
    func testDefaultClientUsesDefaultApiUrls() {
        let client = CourierClient(userId: "test-user")
        let defaultUrls = CourierClient.ApiUrls()
        
        XCTAssertEqual(client.options.apiUrls.rest, defaultUrls.rest)
        XCTAssertEqual(client.options.apiUrls.graphql, defaultUrls.graphql)
        XCTAssertEqual(client.options.apiUrls.inboxGraphql, defaultUrls.inboxGraphql)
        XCTAssertEqual(client.options.apiUrls.inboxWebSocket, defaultUrls.inboxWebSocket)
    }
    
}
