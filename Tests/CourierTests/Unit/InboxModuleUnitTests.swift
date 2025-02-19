//
//  InboxModuleUnitTests.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/14/25.
//

import Foundation
import XCTest
@testable import Courier_iOS

extension InboxMessage {
    
    static func new() -> InboxMessage {
        let id = UUID().uuidString
        return InboxMessage(messageId: id)
    }
    
}

class InboxModuleUnitTests: XCTestCase {
    
    override func tearDown() async throws {
        await Courier.shared.inboxModule.dispose()
        try await super.tearDown()
    }
    
    func testListenerRegistration() async {
        let listener = CourierInboxListener()
        await Courier.shared.inboxModule.addListener(listener)
        let listeners = await Courier.shared.inboxModule.inboxListeners
        XCTAssertEqual(listeners.count, 1, "Total count should increase by 1.")
    }
    
    func testReloadData() async {
        
        // Set initial data
        let initialMessage = InboxMessage.new()
        let initialData = InboxMessageDataSet(messages: [initialMessage], totalCount: 1)
        
        // Reload the data store
        let dataStore = await Courier.shared.inboxModule.dataStore
        await dataStore.updateDataSet(initialData, for: .feed)
        let initialDataStoreMessageCount = await dataStore.feed.messages.count
        XCTAssertEqual(initialDataStoreMessageCount, 1)
        
        // Reload with empty messages
        let newData = InboxMessageDataSet(messages: [])
        await dataStore.updateDataSet(newData, for: .feed)
        let updatedDataStoreMessageCount = await dataStore.feed.messages.count
        XCTAssertEqual(updatedDataStoreMessageCount, 0)
        
    }
    
    func testReadMessage() async {
        
        // Set initial data
        let initialMessage = InboxMessage.new()
        let initialData = InboxMessageDataSet(messages: [initialMessage], totalCount: 1)
        
        // Reload the data store
        let dataStore = await Courier.shared.inboxModule.dataStore
        await dataStore.updateDataSet(initialData, for: .feed)
        await dataStore.updateUnreadCount(1)
        let initialDataStoreMessage = await dataStore.feed.messages.first
        XCTAssertEqual(initialDataStoreMessage?.messageId, initialMessage.messageId)
        let initialUnreadCount = await dataStore.unreadCount
        XCTAssertEqual(initialUnreadCount, 1)
        
        // Read the message
        await dataStore.readMessage(initialMessage, from: .feed, client: nil)
        let updatedDataStoreMessage = await dataStore.feed.messages.first
        XCTAssertEqual(updatedDataStoreMessage?.isRead, true)
        let updatedUnreadCount = await dataStore.unreadCount
        XCTAssertEqual(updatedUnreadCount, 0)
        
    }
    
    func testUnreadMessage() async {
        
        // Set initial data
        let initialMessage = InboxMessage.new()
        initialMessage.setRead()
        let initialData = InboxMessageDataSet(messages: [initialMessage], totalCount: 1)
        
        // Reload the data store
        let dataStore = await Courier.shared.inboxModule.dataStore
        await dataStore.updateDataSet(initialData, for: .feed)
        let initialDataStoreMessage = await dataStore.feed.messages.first
        XCTAssertEqual(initialDataStoreMessage?.messageId, initialMessage.messageId)
        
        // Read the message
        await dataStore.unreadMessage(initialMessage, from: .feed, client: nil)
        let updatedDataStoreMessage = await dataStore.feed.messages.first
        XCTAssertEqual(updatedDataStoreMessage?.isRead, false)
        
    }
    
    func testAddMessage() async {
        
        // Set initial data
        let initialData = InboxMessageDataSet()
        
        // Reload the data store
        let dataStore = await Courier.shared.inboxModule.dataStore
        await dataStore.updateDataSet(initialData, for: .feed)
        let initialDataStoreMessage = await dataStore.feed.messages
        XCTAssertEqual(initialDataStoreMessage.isEmpty, true)
        
        // Add the message
        let newMessage = InboxMessage.new()
        await dataStore.addMessage(newMessage, at: 0, to: .feed)
        
        let updatedDataStoreMessage = await dataStore.feed.messages.first
        XCTAssertEqual(updatedDataStoreMessage?.messageId, newMessage.messageId)
        let updatedUnreadCount = await dataStore.unreadCount
        XCTAssertEqual(updatedUnreadCount, 1)
        
    }
    
    func testArchiveMessage() async {
        
        // Set initial data
        let initialMessage = InboxMessage.new()
        let initialData = InboxMessageDataSet(messages: [initialMessage], totalCount: 1)
        
        // Reload the data store
        let dataStore = await Courier.shared.inboxModule.dataStore
        await dataStore.updateDataSet(initialData, for: .feed)
        await dataStore.updateUnreadCount(1)
        let initialDataStoreMessageCount = await dataStore.feed.messages.count
        XCTAssertEqual(initialDataStoreMessageCount, 1)
        let initialUnreadCount = await dataStore.unreadCount
        XCTAssertEqual(initialUnreadCount, 1)
        let initialFeedTotalCount = await dataStore.feed.totalCount
        XCTAssertEqual(initialFeedTotalCount, 1)
        let initialArchiveTotalCount = await dataStore.archive.totalCount
        XCTAssertEqual(initialArchiveTotalCount, 0)
        
        // Archive the message
        await dataStore.archiveMessage(initialMessage, from: .feed, client: nil)
        
        let updatedDataStoreMessageCount = await dataStore.feed.messages.count
        XCTAssertEqual(updatedDataStoreMessageCount, 0)
        let updatedUnreadCount = await dataStore.unreadCount
        XCTAssertEqual(updatedUnreadCount, 0)
        let archiveCount = await dataStore.archive.messages.count
        XCTAssertEqual(archiveCount, 1)
        let updatedFeedTotalCount = await dataStore.feed.totalCount
        XCTAssertEqual(updatedFeedTotalCount, 0)
        let updatedArchiveTotalCount = await dataStore.archive.totalCount
        XCTAssertEqual(updatedArchiveTotalCount, 1)
        
    }
    
    func testOpenMessage() async {
        
        // Set initial data
        let initialMessage = InboxMessage.new()
        let initialData = InboxMessageDataSet(messages: [initialMessage], totalCount: 1)
        
        // Reload the data store
        let dataStore = await Courier.shared.inboxModule.dataStore
        await dataStore.updateDataSet(initialData, for: .feed)
        await dataStore.updateUnreadCount(1)
        let initialDataStoreMessageCount = await dataStore.feed.messages.count
        XCTAssertEqual(initialDataStoreMessageCount, 1)
        let initialUnreadCount = await dataStore.unreadCount
        XCTAssertEqual(initialUnreadCount, 1)
        let initialFeedTotalCount = await dataStore.feed.totalCount
        XCTAssertEqual(initialFeedTotalCount, 1)
        let initialArchiveTotalCount = await dataStore.archive.totalCount
        XCTAssertEqual(initialArchiveTotalCount, 0)
        
        // Archive the message
        await dataStore.openMessage(initialMessage, from: .feed, client: nil)
        
        let updatedDataStoreMessageCount = await dataStore.feed.messages.count
        XCTAssertEqual(updatedDataStoreMessageCount, 1)
        let updatedUnreadCount = await dataStore.unreadCount
        XCTAssertEqual(updatedUnreadCount, 1)
        let updatedMessage = await dataStore.feed.messages.first
        XCTAssertEqual(updatedMessage?.isOpened, true)
        let updatedFeedTotalCount = await dataStore.feed.totalCount
        XCTAssertEqual(updatedFeedTotalCount, 1)
        let updatedArchiveTotalCount = await dataStore.archive.totalCount
        XCTAssertEqual(updatedArchiveTotalCount, 0)
        
    }
    
    func testConcurrentAddMessages() async {
        let dataStore = await Courier.shared.inboxModule.dataStore
        await dataStore.updateDataSet(InboxMessageDataSet(), for: .feed)

        // Concurrently add 20 messages
        async let task1: () = Task {
            for i in 0..<10 {
                let message = InboxMessage(messageId: "msg_\(i)")
                await dataStore.addMessage(message, at: 999, to: .feed)
                print("Inserting message with: \(message.messageId)")
            }
        }.value

        async let task2: () = Task {
            for i in 10..<20 {
                let message = InboxMessage(messageId: "msg_\(i)")
                await dataStore.addMessage(message, at: 999, to: .feed)
                print("Inserting message with: \(message.messageId)")
            }
        }.value

        await task1
        await task2

        // Validate total message count
        let totalMessages = await dataStore.feed.messages.count
        XCTAssertEqual(totalMessages, 20, "Total messages should be 20 after concurrent inserts.")
    }
    
    func testConcurrentReading() async {
        
        let dataStore = await Courier.shared.inboxModule.dataStore
        
        func getMessage() -> InboxMessage {
            let message = InboxMessage(messageId: UUID().uuidString)
            message.setUnread()
            return message
        }
        
        let unreadCount = 3
        let initialData = InboxMessageDataSet(messages: (0..<unreadCount).map { _ in getMessage() })
        await dataStore.updateDataSet(initialData, for: .feed)
        await dataStore.updateUnreadCount(unreadCount)

        // Run concurrent read operations
        let tasks = (0..<unreadCount).map { index in
            Task {
                
                // Get the message
                let message = await dataStore.feed.messages[index]
                
                // Random delay
                let randomDelay = UInt64.random(in: 10_000_000...100_000_000)
                try? await Task.sleep(nanoseconds: randomDelay)
                
                // Read the message
                await dataStore.readMessage(message, from: .feed, client: nil)
                print("Message read \(message.messageId) at index: \(index)")
                
            }
        }

        // Await all tasks
        for task in tasks {
            await task.value
        }

        // Validate
        let totalMessages = await dataStore.feed.messages.count
        XCTAssertEqual(totalMessages, unreadCount)
        
        let feedMessages = await dataStore.feed.messages
        feedMessages.forEach { message in
            XCTAssertEqual(message.isRead, true)
        }
        
        let unreadFeedCount = await dataStore.unreadCount
        XCTAssertEqual(unreadFeedCount, 0)
        
    }
    
    func testInitializeData() async throws {
        
        let userId = UUID().uuidString
        
        // Send message
        let messageId = try await ExampleServer().sendTest(authKey: Env.COURIER_AUTH_KEY, userId: userId, key: "inbox")
        
        // Get JWT
        let jwt = try await ExampleServer().generateJwt(authKey: Env.COURIER_AUTH_KEY,userId: userId)
        
        // Delay
        try? await Task.sleep(nanoseconds: 10_000_000_000)
        
        // Auth
        await Courier.shared.signIn(userId: userId, accessToken: jwt)
        
        // Get data
        await Courier.shared.inboxModule.getInbox(isRefresh: false)
        
        let dataStore = await Courier.shared.inboxModule.dataStore
        
        // Ensure data exists
        let unreadFeedCount = await dataStore.unreadCount
        XCTAssertEqual(unreadFeedCount, 1)
        
        let message = await dataStore.feed.messages.first
        XCTAssertEqual(message?.messageId, messageId)
        
        // Signout
        await Courier.shared.signOut()
        
    }

    
}
