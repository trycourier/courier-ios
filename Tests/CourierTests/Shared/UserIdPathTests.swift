//
//  UserIdPathTests.swift
//

import Foundation

import XCTest
@testable import Courier_iOS

// The API stores a user id path segment as sent, without decoding `%2B`, `%40` or `%3A`.
// A token set for a plus-addressed user has to land on that exact user id.
class UserIdPathTests: XCTestCase {

    func testPlusAddressedUserGetsItsOwnToken() async throws {

        let suffix = UUID().uuidString.lowercased()
        let userId = "ios+plus-\(suffix)@example.com"
        let token = "fcm-\(suffix):APA91bTest_token-value"

        try await UserBuilder.authenticate(userId: userId)
        try await Courier.shared.setToken(for: .firebaseFcm, token: token)

        // The JWT is for this exact user, so a path naming another user is refused
        let client = await Courier.shared.client
        _ = try await XCTUnwrap(client).preferences.getUserPreferences()

        var stored: [String] = []
        for _ in 0..<15 {
            stored = try await ExampleServer.getUserTokens(authKey: Env.COURIER_AUTH_KEY, userId: userId).map(\.token)
            if stored.contains(token) { break }
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        // Where an encoded `+` sends it instead
        let encodedUserId = "ios%2Bplus-\(suffix)@example.com"
        let misplaced = try await ExampleServer.getUserTokens(authKey: Env.COURIER_AUTH_KEY, userId: encodedUserId).map(\.token)
        print("UserIdPathTests: \(userId) has \(stored), \(encodedUserId) has \(misplaced)")

        try? await Courier.shared.client?.tokens.deleteUserToken(token: token)
        await Courier.shared.signOut()

        XCTAssertTrue(stored.contains(token), "\(userId) has \(stored); \(encodedUserId) has \(misplaced)")

    }

}
