//
//  CoreClientTests.swift
//
//
//  Created by Michael Miller on 7/23/24.
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
        XCTAssertEqual(client1?.options, client2?.options)
        
        let client3 = try await ClientBuilder.build()
        
        XCTAssertNotEqual(client1?.options, client3.options)
        XCTAssertNotEqual(client2?.options, client3.options)
        
        await Courier.shared.signOut()
        
        XCTAssertNil(Courier.shared.client, "Shared client is nil")
        XCTAssertNotNil(client3)

    }
    
}
