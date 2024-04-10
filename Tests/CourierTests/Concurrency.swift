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
    
    func testTokenSync() async throws {
        
        print("\n🔬 Testing Concurrency")
        
        try await Courier.shared.signOut()
        
        try await Courier.shared.signIn(
            accessToken: Env.COURIER_AUTH_KEY,
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: "example_1"
        )
        
        let token = try await spamTokens()
        
        print(token)

    }
    
    func spamTokens() async throws -> String {
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            
            for _ in 1...100 {
                group.addTask { [self] in
                    try await Courier.shared.setAPNSToken(rawApnsToken)
                    return ""
                }
            }

            try await group.waitForAll()
            print("All tasks have completed")
            
            return (await Courier.shared.getAPNSToken())?.string ?? "Missing"
            
        }
        
    }
    
    func testInboxListener() async throws {
        
        print("\n🔬 Testing Inbox Listener")
        
        try await Courier.shared.signOut()
        
        let userId = "asdf"
        
        try await Courier.shared.signIn(
            accessToken: Env.COURIER_AUTH_KEY,
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: userId
        )
        
        Courier.shared.addInboxListener(onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
            print(messages.count)
        })
        
        _ = try await spamMessages(userId: userId)

    }
    
    func spamMessages(userId: String) async throws -> String {
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            
            for _ in 1...100 {
                group.addTask {
                    let messageId = try await ExampleServer().sendTest(authKey: Env.COURIER_AUTH_KEY, userId: userId, key: "inbox")
                    print(messageId)
                    return messageId
                }
            }

            try await group.waitForAll()
            print("All tasks have completed")
            
            return "Missing"
            
        }
        
    }
    
}
