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
        
        let client1 = await Courier.shared.client
        let client2 = await Courier.shared.client
        
        XCTAssertNotNil(client1)
        XCTAssertNotNil(client2)
        XCTAssertEqual(client1?.options.userId, client2?.options.userId)
        
        let client3 = try await ClientBuilder.build(userId: "example_1")
        
        XCTAssertNotEqual(client1?.options.userId, client3.options.userId)
        XCTAssertNotEqual(client2?.options.userId, client3.options.userId)
        
        await Courier.shared.signOut()
        
        let courierClient = await Courier.shared.client
        XCTAssertNil(courierClient, "Shared client is nil")
        XCTAssertNotNil(client3)

    }
    
    @CourierActor func testUserAgent() throws {
        
        Courier.agent = CourierAgent.nativeIOS("1.2.3")
        XCTAssertEqual(Courier.agent.value, "courier-ios/1.2.3")
        
        Courier.agent = CourierAgent.flutterIOS("1.2.3")
        XCTAssertEqual(Courier.agent.value, "courier-flutter-ios/1.2.3")
        
        Courier.agent = CourierAgent.reactNativeIOS("1.2.3")
        XCTAssertEqual(Courier.agent.value, "courier-react-native-ios/1.2.3")
        
    }
    
}
