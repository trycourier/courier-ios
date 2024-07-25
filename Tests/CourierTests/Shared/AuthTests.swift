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

        var hold = true

        let listener = Courier.shared.addAuthenticationListener { userId in
            print(userId)
            if (userId != nil) {
                hold = false
            }
        }

        await Courier.shared.signIn(
            userId: Env.COURIER_USER_ID, 
            accessToken: Env.COURIER_AUTH_KEY
        )

        XCTAssertTrue(Courier.shared.accessToken == Env.COURIER_AUTH_KEY)
        XCTAssertTrue(Courier.shared.userId == Env.COURIER_USER_ID)
        XCTAssertTrue(Courier.shared.clientKey == nil)

        while (hold) {
            // Hold for auth listener
        }

        listener.remove()

        XCTAssertTrue(Courier.shared.authListeners.isEmpty)

    }

    func testSignUserOut() async throws {

        var hold = true

        let listener = Courier.shared.addAuthenticationListener { userId in
            print(userId)
            if (userId == nil) {
                hold = false
            }
        }

        await Courier.shared.signOut()

        XCTAssertTrue(Courier.shared.accessToken == nil)
        XCTAssertTrue(Courier.shared.userId == nil)
        XCTAssertTrue(Courier.shared.clientKey == nil)

        while (hold) {
            // Hold for auth listener
        }

        listener.remove()

        XCTAssertTrue(Courier.shared.authListeners.isEmpty)

    }
    
}
