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
        
        // Send a message and wait for delivery confirmation
        let jwt = try await ExampleServer.generateJwt(authKey: Env.COURIER_AUTH_KEY, userId: client.options.userId)
        await Courier.shared.signIn(userId: client.options.userId, accessToken: jwt)
        let (sentMessage, listener) = try await Utils.sendMessageAndWaitForDelivery(to: client.options.userId)
        await Courier.shared.removeInboxListener(listener)
        
        try await client.inbox.archive(messageId: sentMessage.messageId)
        
        // This is a bit strange that it does not update state instantly...
        // We have to wait for something to happen on the backend and update the state
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
            Task {
                try await socket.connect(
                    receivedMessage: { message in
                        print("socket.receivedMessage")
                        print(message)
                        continuation.resume()
                    },
                    receivedMessageEvent: { event in
                        print(event)
                    }
                )
                try await socket.sendSubscribe()
                try await sendMessage(userId: userId)
            }
        }

        await socket.disconnect()
    }
    
    func testTemplateMessage() async throws {
        let userId = UUID().uuidString
        let client = try await ClientBuilder.build(userId: userId)
        let socket = client.inbox.socket

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                try await socket.connect(
                    receivedMessage: { message in
                        print("socket.receivedMessage")
                        print(message)
                        continuation.resume()
                    },
                    receivedMessageEvent: { event in
                        print(event)
                    }
                )
                try await socket.sendSubscribe()
                try await sendMessageTemplate(userId: userId)
            }
        }

        await socket.disconnect()
    }
    
    actor SocketMessageCounter {
        
        private let maxCount: Int
        
        init(maxCount: Int) {
            self.maxCount = maxCount
        }
        
        private var count = 0
        
        func increment() -> Bool {
            count += 1
            return count >= maxCount
        }
    }

    func testMultipleSocketsOnSingleUser() async throws {
        
        let client1 = try await ClientBuilder.build(connectionId: UUID().uuidString)
        let socket1 = client1.inbox.socket

        let client2 = try await ClientBuilder.build(connectionId: UUID().uuidString)
        let socket2 = client2.inbox.socket

        let counter = SocketMessageCounter(maxCount: [socket1, socket2].count)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                do {
                    // Socket 1 connection
                    try await socket1.connect(receivedMessage: { _ in
                        Task {
                            if await counter.increment() {
                                continuation.resume()
                            }
                        }
                    })
                    try await socket1.sendSubscribe()

                    // Socket 2 connection
                    try await socket2.connect(receivedMessage: { _ in
                        Task {
                            if await counter.increment() {
                                continuation.resume()
                            }
                        }
                    })
                    try await socket2.sendSubscribe()

                    let messageId = try await sendMessage()
                    print("Sent message with ID: \(messageId)")
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
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

        let counter = SocketMessageCounter(maxCount: [socket1, socket2].count)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                do {
                    // Socket 1 connection
                    try await socket1.connect(receivedMessage: { _ in
                        Task {
                            if await counter.increment() {
                                continuation.resume()
                            }
                        }
                    })
                    try await socket1.sendSubscribe()

                    // Socket 2 connection
                    try await socket2.connect(receivedMessage: { _ in
                        Task {
                            if await counter.increment() {
                                continuation.resume()
                            }
                        }
                    })
                    try await socket2.sendSubscribe()

                    // Send a message to each user
                    try await sendMessage(userId: userId1)
                    try await sendMessage(userId: userId2)
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        await socket1.disconnect()
        await socket2.disconnect()
    }
    
}
