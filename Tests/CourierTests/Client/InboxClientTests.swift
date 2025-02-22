//
//  InboxClientTests.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
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
    
    @discardableResult
    private func sendMessageTemplate(userId: String? = nil) async throws -> String {
        return try await ExampleServer.sendTemplateTest(
            authKey: Env.COURIER_AUTH_KEY,
            userId: userId ?? client.options.userId,
            templateId: Env.COURIER_MESSAGE_TEMPLATE_ID
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
        
        let messageId = try await sendMessage(userId: client.options.userId)
        
        try? await Task.sleep(nanoseconds: delay)
        
        try await client.inbox.archive(messageId: messageId)
        
        try? await Task.sleep(nanoseconds: delay)
        
        let limit = 24
        
        let res = try await client.inbox.getArchivedMessages(
            paginationLimit: limit,
            startCursor: nil
        )
        
        let message = res.data!.messages!.nodes?.first
        
        XCTAssertTrue(message?.isArchived == true)

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
//        try await client.inbox.click(...)

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
    
    func testContentMessage() async throws {
        
        let userId = UUID().uuidString
        var caughtError: Error?
        var hold = true
        
        let client = try await ClientBuilder.build(userId: userId)
        
        let socket = client.inbox.socket

        socket.onError = { error in
            hold = false
            caughtError = error
        }

        socket.receivedMessageEvent = { event in
            print(event)
        }

        socket.receivedMessage = { message in
            print("socket.receivedMessage")
            print(message)
            hold = false
        }
        
        try await socket.connect()
        try await socket.sendSubscribe()
        
        try await sendMessage(userId: userId)
        
        while hold {}
        
        socket.disconnect()
        
        if let error = caughtError {
            throw error
        }
        
    }
    
    func testTemplateMessage() async throws {
        
        let userId = UUID().uuidString
        var caughtError: Error?
        var hold = true
        
        let client = try await ClientBuilder.build(userId: userId)
        
        let socket = client.inbox.socket

        socket.onError = { error in
            hold = false
            caughtError = error
        }

        socket.receivedMessageEvent = { event in
            print(event)
        }

        socket.receivedMessage = { message in
            print("socket.receivedMessage")
            print(message)
            hold = false
        }
        
        try await socket.connect()
        try await socket.sendSubscribe()
        
        try await sendMessageTemplate(userId: userId)
        
        while hold {}
        
        socket.disconnect()
        
        if let error = caughtError {
            throw error
        }
        
    }
    
    func testMultipleSocketsOnSingleUser() async throws {

        var hold1 = true
        var hold2 = true

        // Open the first socket connection
        let client1 = try await ClientBuilder.build(connectionId: UUID().uuidString)
        
        let socket1 = client1.inbox.socket

        socket1.onOpen = {
            print("Socket Opened")
        }

        socket1.onClose = { code, reason in
            print("Socket closed: \(code), \(String(describing: reason))")
        }

        socket1.onError = { error in
            XCTAssertNil(error)
        }

        socket1.receivedMessageEvent = { event in
            print(event)
        }

        socket1.receivedMessage = { message in
            print("socket1.receivedMessage")
            print(message)
            hold1 = false
        }

        try await socket1.connect()
        try await socket1.sendSubscribe()

        // Open the second socket connection
        let client2 = try await ClientBuilder.build(connectionId: UUID().uuidString)
        
        let socket2 = client2.inbox.socket

        socket2.onOpen = {
            print("Socket Opened")
        }

        socket2.onClose = { code, reason in
            print("Socket closed: \(code), \(String(describing: reason))")
        }

        socket2.onError = { error in
            XCTAssertNil(error)
        }

        socket2.receivedMessageEvent = { event in
            print(event)
        }

        socket2.receivedMessage = { message in
            print("socket2.receivedMessage")
            print(message)
            hold2 = false
        }

        try await socket2.connect()
        try await socket2.sendSubscribe()

        let messageId = try await sendMessage()

        print(messageId)

        while (hold1 || hold2) {
            // Wait for the message to be received in the sockets
        }

        client1.inbox.socket.disconnect()
        client2.inbox.socket.disconnect()

    }
    
    func testMultipleUserConnections() async throws {

        let userId1 = "user_1"
        let userId2 = "user_2"

        var hold1 = true
        var hold2 = true

        // Open the first socket connection
        let client1 = try await ClientBuilder.build(userId: userId1)
        
        let socket1 = client1.inbox.socket
        
        socket1.onError = { error in
            print(error.localizedDescription)
            hold1 = false
            hold2 = false
        }
        
        socket1.receivedMessage = { message in
            print(message)
            hold1 = false
        }
        
        try await socket1.connect()
        try await socket1.sendSubscribe()

        // Open the second socket connection
        let client2 = try await ClientBuilder.build(userId: userId2)
        
        let socket2 = client2.inbox.socket
        
        socket2.onError = { error in
            print(error.localizedDescription)
            hold1 = false
            hold2 = false
        }
        
        socket2.receivedMessage = { message in
            print(message)
            hold2 = false
        }
        
        try await socket2.connect()
        try await socket2.sendSubscribe()

        // Send a message to each user
        try await sendMessage(userId: userId1)
        try await sendMessage(userId: userId2)

        while (hold1 || hold2) {
            // Wait for the message to be received in the sockets
        }

        client1.inbox.socket.disconnect()
        client2.inbox.socket.disconnect()

    }
    
}
