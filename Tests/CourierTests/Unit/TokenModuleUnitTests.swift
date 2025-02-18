//
//  TokenModuleUnitTests.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/18/25.
//

import Foundation
import XCTest
@testable import Courier_iOS

class TokenModuleUnitTests: XCTestCase {
    
    override func tearDown() async throws {
        await Courier.shared.tokenModule.dispose()
        try await super.tearDown()
    }
    
    func testCacheToken() async {
        await Courier.shared.tokenModule.cacheToken(key: "example_provider", value: "example_token")
        let token = await Courier.shared.tokenModule.tokens["example_provider"]
        XCTAssertEqual(token, "example_token")
    }
    
    func testApnsToken() async {
        let exampleToken = TokenTests.generateAPNSToken()
        await Courier.shared.tokenModule.setApnsToken(exampleToken)
        let apnsToken = await Courier.shared.tokenModule.apnsToken
        XCTAssertEqual(apnsToken, exampleToken)
    }
    
}
