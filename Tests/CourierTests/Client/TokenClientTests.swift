//
//  TokenClientTests.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
//

import XCTest
@testable import Courier_iOS

class TokenClientTests: XCTestCase {

    // A real APNs device token is 32 bytes (64 hex characters). This is deliberately not one --
    // it is a fixture, and registering it against the workspace's live APNs provider means pushes
    // to this user come back BadDeviceToken. That is correct behaviour, not a misconfiguration.
    private let exampleToken = "f371039a5459ee369f7223cf94cc8638"

    /// Reads the token back from the API. `putUserToken` returning without throwing proves only
    /// that the request was accepted, not that anything was stored.
    private func storedToken(for client: CourierClient) async throws -> ExampleServer.StoredToken? {
        let tokens = try await ExampleServer.getUserTokens(
            authKey: Env.COURIER_AUTH_KEY,
            userId: client.options.userId
        )
        return tokens.first { $0.token == exampleToken }
    }

    func testUpsertToken() async throws {

        let client = try await ClientBuilder.build()

        try await client.tokens.putUserToken(
            token: exampleToken,
            provider: "apn"
        )

        let stored = try await storedToken(for: client)

        XCTAssertNotNil(stored, "Token was not persisted")
        XCTAssertEqual(stored?.providerKey, "apn")

    }

    func testUpsertTokenWithCustomDevice() async throws {

        let client = try await ClientBuilder.build()

        let device = CourierDevice(
            appId: "APP_ID",
            adId: "AD_ID",
            deviceId: "DEVICE_ID",
            platform: "apple",
            manufacturer: "Apple",
            model: "iPhone 99"
        )

        try await client.tokens.putUserToken(
            token: exampleToken,
            provider: "apn",
            device: device
        )

        let stored = try await storedToken(for: client)

        XCTAssertNotNil(stored, "Token was not persisted")
        XCTAssertEqual(stored?.providerKey, "apn")

        // Every field must survive the round trip, not just the token itself.
        XCTAssertEqual(stored?.device?.appId, "APP_ID")
        XCTAssertEqual(stored?.device?.adId, "AD_ID")
        XCTAssertEqual(stored?.device?.deviceId, "DEVICE_ID")
        XCTAssertEqual(stored?.device?.platform, "apple")
        XCTAssertEqual(stored?.device?.manufacturer, "Apple")
        XCTAssertEqual(stored?.device?.model, "iPhone 99")

    }

    func testDeleteToken() async throws {

        let client = try await ClientBuilder.build()

        // Ensure there is something to delete, so the assertion below means something even when
        // this test runs before the upsert tests.
        try await client.tokens.putUserToken(
            token: exampleToken,
            provider: "apn"
        )

        try await client.tokens.deleteUserToken(
            token: exampleToken
        )

        let stored = try await storedToken(for: client)

        XCTAssertNil(stored, "Token still present after delete")

    }

}
