//
//  CoreClientTests.swift
//
//
//  Created by https://github.com/mikemilla on 7/23/24.
//

import XCTest
@testable import Courier_iOS

class CoreClientTests: XCTestCase {
    
    func testClientSingletonTest() async throws {

        try await UserBuilder.authenticate()
        
        let client1 = Courier.shared.client
        let client2 = Courier.shared.client
        
        XCTAssertNotNil(client1)
        XCTAssertNotNil(client2)
        XCTAssertEqual(client1?.options.userId, client2?.options.userId)
        
        let client3 = try await ClientBuilder.build(userId: "example_1")
        
        XCTAssertNotEqual(client1?.options.userId, client3.options.userId)
        XCTAssertNotEqual(client2?.options.userId, client3.options.userId)
        
        await Courier.shared.signOut()
        
        XCTAssertNil(Courier.shared.client, "Shared client is nil")
        XCTAssertNotNil(client3)

    }
    
}
