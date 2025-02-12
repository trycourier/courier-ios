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
        let client = try await ClientBuilder.build(userId: userId)
        let socket = client.inbox.socket

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            
            // Handle socket errors
            socket.onError = { error in
                continuation.resume(throwing: error)
            }

            // Optional: Handle message events if needed
            socket.receivedMessageEvent = { event in
                print(event)
            }

            // Handle received messages
            socket.receivedMessage = { message in
                print("socket.receivedMessage")
                print(message)
                continuation.resume() // Resume on message reception
            }
            
            Task {
                do {
                    try await socket.connect()
                    try await socket.sendSubscribe()
                    try await sendMessage(userId: userId)
                } catch {
                    continuation.resume(throwing: error) // Resume with failure if any error occurs
                }
            }
        }

        await socket.disconnect()
    }
    
    func testTemplateMessage() async throws {
        let userId = UUID().uuidString
        let client = try await ClientBuilder.build(userId: userId)
        let socket = client.inbox.socket

        // Use continuation to await until the test completes
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            
            // Handle socket errors
            socket.onError = { error in
                continuation.resume(throwing: error) // Directly throw the error
            }

            // Handle received message events (if needed)
            socket.receivedMessageEvent = { event in
                print(event)
            }

            // Handle received messages
            socket.receivedMessage = { message in
                print("socket.receivedMessage")
                print(message)
                continuation.resume() // Resume normally on success
            }

            // Move async operations into a Task
            Task {
                do {
                    try await socket.connect()
                    try await socket.sendSubscribe()
                    try await sendMessageTemplate(userId: userId)
                } catch {
                    continuation.resume(throwing: error) // Resume with failure if any error occurs
                }
            }
        }

        await socket.disconnect()
    }
    
    func testMultipleSocketsOnSingleUser() async throws {
        // Open the first socket connection
        let client1 = try await ClientBuilder.build(connectionId: UUID().uuidString)
        let socket1 = client1.inbox.socket

        // Open the second socket connection
        let client2 = try await ClientBuilder.build(connectionId: UUID().uuidString)
        let socket2 = client2.inbox.socket

        // Helper function to handle socket events and return when a message is received
        func waitForMessage(socket: InboxSocket) async -> Result<Void, Error> {
            return await withCheckedContinuation { (continuation: CheckedContinuation<Result<Void, Error>, Never>) in
                socket.onOpen = {
                    print("Socket Opened")
                }
                
                socket.onClose = { code, reason in
                    print("Socket closed: \(code), \(String(describing: reason))")
                }
                
                socket.onError = { error in
                    continuation.resume(returning: .failure(error))
                }
                
                socket.receivedMessageEvent = { event in
                    print(event)
                }
                
                socket.receivedMessage = { message in
                    print("Received message on socket: \(message)")
                    continuation.resume(returning: .success(()))
                }
            }
        }

        try await socket1.connect()
        try await socket1.sendSubscribe()

        try await socket2.connect()
        try await socket2.sendSubscribe()

        let messageId = try await sendMessage()
        print("Sent message with ID: \(messageId)")

        // Wait for both sockets to receive the message concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                let result = await waitForMessage(socket: socket1)
                if case .failure(let error) = result {
                    throw error
                }
            }
            
            group.addTask {
                let result = await waitForMessage(socket: socket2)
                if case .failure(let error) = result {
                    throw error
                }
            }

            try await group.waitForAll()
        }

        await socket1.disconnect()
        await socket2.disconnect()
    }
    
    func testMultipleUserConnections() async throws {
        let userId1 = "user_1"
        let userId2 = "user_2"

        // Open the first socket connection
        let client1 = try await ClientBuilder.build(userId: userId1)
        let socket1 = client1.inbox.socket

        // Open the second socket connection
        let client2 = try await ClientBuilder.build(userId: userId2)
        let socket2 = client2.inbox.socket

        // Helper function to handle socket events and await message reception
        func waitForMessage(socket: InboxSocket) async -> Result<Void, Error> {
            return await withCheckedContinuation { (continuation: CheckedContinuation<Result<Void, Error>, Never>) in
                socket.onError = { error in
                    print(error.localizedDescription)
                    continuation.resume(returning: .failure(error))
                }

                socket.receivedMessage = { message in
                    print("Received message: \(message)")
                    continuation.resume(returning: .success(()))
                }
            }
        }

        try await socket1.connect()
        try await socket1.sendSubscribe()

        try await socket2.connect()
        try await socket2.sendSubscribe()

        // Send a message to each user
        try await sendMessage(userId: userId1)
        try await sendMessage(userId: userId2)

        // Wait for both sockets to receive messages concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                let result = await waitForMessage(socket: socket1)
                if case .failure(let error) = result {
                    throw error
                }
            }

            group.addTask {
                let result = await waitForMessage(socket: socket2)
                if case .failure(let error) = result {
                    throw error
                }
            }

            try await group.waitForAll()
        }

        await socket1.disconnect()
        await socket2.disconnect()
    }
    
}
