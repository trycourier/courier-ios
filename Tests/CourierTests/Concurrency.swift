//
//  File.swift
//  
//
//  Created by Michael Miller on 12/21/23.
//

import XCTest
@testable import Courier_iOS

final class Concurrency: XCTestCase {
    
    let rawApnsToken = Data([110, 157, 218, 189])
    
    func test() async throws {
        
        print("\n🔬 Testing Concurrency")
        
        try await Courier.shared.signIn(
            accessToken: Env.COURIER_AUTH_KEY,
            userId: "example_1"
        )
        
        let token = try await spamTokens()
        
        print(token)

    }
    
    func spamTokens() async throws -> String {
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            
            for i in 1...10 {
                group.addTask { [self] in
                    try await Courier.shared.setAPNSToken(rawApnsToken)
                    return ""
                }
            }

            try await group.waitForAll()
            print("All tasks have completed")
            
            return (await Courier.shared.getApnsToken())?.string ?? "Missing"
            
        }
        
    }
    
}
