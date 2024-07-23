//
//  InboxClientTests.swift
//
//
//  Created by Michael Miller on 7/22/24.
//

import XCTest
@testable import Courier_iOS

class InboxClientTests: XCTestCase {
    
    private var client: CourierClient!
    private let connectionId = UUID().uuidString
    private let delay: UInt64 = 5_000_000_000
    
    override func setUp() async throws {
        
        self.client = try await ClientBuilder.build(
            connectionId: self.connectionId
        )
        
        try await super.setUp()
        
    }
    
    @discardableResult
    private func sendMessage(userId: String? = nil) async throws -> String {
        return try await ExampleServer.sendTest(
            authKey: Env.COURIER_AUTH_KEY,
            userId: userId ?? client.options.userId,
            channel: "inbox"
        )
    }
    
    func testGetInboxMessage() async throws {

        let messageId = try await sendMessage()
        
        try? await Task.sleep(nanoseconds: delay)
        
        let res = try await client.inbox.getMessage(
            messageId: messageId
        )
        
        XCTAssertNotNil(res)

    }
    
    func testGetAllMessages() async throws {
        
        let limit = 24
        
        let res = try await client.inbox.getMessages(
            paginationLimit: limit,
            startCursor: nil
        )
        
        XCTAssertTrue(res.data!.messages!.nodes!.count <= limit)

    }
    
    func testGetAllArchivedMessages() async throws {
        
        let limit = 24
        
        let res = try await client.inbox.getArchivedMessages(
            paginationLimit: limit,
            startCursor: nil
        )
        
        XCTAssertTrue(res.data!.messages!.nodes!.count <= limit)

    }
    
    func testGetUnreadCount() async throws {
        
        try await sendMessage()
        
        try? await Task.sleep(nanoseconds: delay)
        
        let count = try await client.inbox.getUnreadMessageCount()
        
        XCTAssertTrue(count >= 1)

    }
    
    func testClick() async throws {
        
        print("Skipped Click Tracking Inbox Message. Needs updates.")
        
//        let messageId = try await sendMessage()
//        
//        try? await Task.sleep(nanoseconds: 5_000_000_000)
//        
//        let count = try await client.inbox.getUnreadMessageCount()
//        
//        XCTAssertTrue(count == 1)

    }
    
    func testRead() async throws {
        
        let messageId = try await sendMessage()
        
        try await client.inbox.read(
            messageId: messageId
        )

    }
    
    func testUnread() async throws {
        
        let messageId = try await sendMessage()
        
        try await client.inbox.unread(
            messageId: messageId
        )

    }
    
    func testOpen() async throws {
        
        let messageId = try await sendMessage()
        
        try await client.inbox.open(
            messageId: messageId
        )

    }
    
    func testArchive() async throws {
        
        let messageId = try await sendMessage()
        
        try await client.inbox.archive(
            messageId: messageId
        )

    }
    
    func testReadAll() async throws {
        
        try await client.inbox.readAll()

    }
    
}
