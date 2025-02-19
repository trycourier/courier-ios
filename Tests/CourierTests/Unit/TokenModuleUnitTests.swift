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
    
    func testConcurrentTokenWrites() async throws {
        
        let count = 25
        
        let writes = try await withThrowingTaskGroup(of: Void.self) { innerGroup in
            var tokens: [String] = []
            for i in 1...count {
                let key = "provider\(i)"
                let value = "token\(i)"
                innerGroup.addTask {
                    await Courier.shared.tokenModule.cacheToken(key: key, value: value)
                    await Courier.shared.tokenModule.cacheToken(key: key, value: nil)
                    await Courier.shared.tokenModule.cacheToken(key: key, value: value)
                }
                tokens.append(value)
            }
            try await innerGroup.waitForAll()
            return tokens
        }
        
        print(writes)
        
        XCTAssertEqual(writes.count, count)
        
        for i in 1...writes.count {
            let checkingToken = "token\(i)"
            let currentToken = writes[i - 1]
            XCTAssertEqual(checkingToken, currentToken)
        }
        
    }
    
}
