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

        let listener = await Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No user found")
            if (userId != nil) {
                hold = false
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

        while (hold) {}

        await Courier.shared.removeAuthenticationListener(listener)

        let listeners = await Courier.shared.authListeners.isEmpty
        XCTAssertTrue(listeners)

    }

    func testSignUserOut() async throws {

        var hold = true

        let listener = await Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No user found")
            if (userId == nil) {
                hold = false
            }
        }

        await Courier.shared.signOut()
        
        let missingAccessToken = await Courier.shared.accessToken == nil
        XCTAssertTrue(missingAccessToken)
        
        let missingUserId = await Courier.shared.userId == nil
        XCTAssertTrue(missingUserId)
        
        let missingClientKey = await Courier.shared.clientKey == nil
        XCTAssertTrue(missingClientKey)

        while (hold) {}

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
    
}
