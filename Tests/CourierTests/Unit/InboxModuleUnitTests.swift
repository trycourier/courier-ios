//
//  InboxModuleUnitTests.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/14/25.
//

import Foundation

import XCTest
@testable import Courier_iOS

class InboxModuleUnitTests: XCTestCase {
    
    override func tearDown() async throws {
        await Courier.shared.newInboxModule.dispose()
        try await super.tearDown()
    }
    
    func testListenerRegistration() async {
        let listener = CourierInboxListener()
        await Courier.shared.newInboxModule.addListener(listener)
        let listeners = await Courier.shared.newInboxModule.inboxListeners
        XCTAssertEqual(listeners.count, 1, "Total count should increase by 1.")
    }
    
    func testAddMessageToFeed() async {
        
        let id = UUID().uuidString
        
        // Arrange: Create a new message and get initial count
        let newMessage = InboxMessage(messageId: id)
        let dataStore = await Courier.shared.newInboxModule.dataStore
        
        // Act: Add message to feed at index 0
        await dataStore.addMessage(newMessage, at: 0, to: .feed)
        
        // Assert: Check if the message is in the feed
        let storedMessage = await dataStore.feed.messages.first
        let totalCount = await dataStore.feed.totalCount
        let unreadCount = await dataStore.unreadCount
        
        XCTAssertEqual(totalCount, 1, "Total count should increase by 1 after adding a message.")
        XCTAssertEqual(storedMessage?.messageId, id, "The first message in the feed should match the added message.")
        XCTAssertEqual(unreadCount, 1, "Unread count should increase by 1 after adding a message to feed.")
        
    }
    
    func testAddMessageToFeed_OutOfBounds() async {
        
        let id = UUID().uuidString
        
        // Arrange: Create a new message and get initial count
        let newMessage = InboxMessage(messageId: id)
        let dataStore = await Courier.shared.newInboxModule.dataStore
        
        // Act: Add message to feed at index 0
        await dataStore.addMessage(newMessage, at: 999, to: .feed)
        
        // Assert: Check if the message is in the feed
        let storedMessage = await dataStore.feed.messages.first
        let count = await dataStore.feed.totalCount
        let unreadCount = await dataStore.unreadCount
        
        XCTAssertEqual(count, 1, "Total count should increase by 1 after adding a message.")
        XCTAssertEqual(storedMessage?.messageId, id, "The first message in the feed should match the added message.")
        XCTAssertEqual(unreadCount, 1, "Unread count should increase by 1 after adding a message to feed.")
    }
    
    func testAddMessageToArchive() async {
        
        let id = UUID().uuidString
        
        // Arrange: Create a new message and get initial count
        let newMessage = InboxMessage(messageId: id)
        let dataStore = await Courier.shared.newInboxModule.dataStore
        
        // Act: Add message to feed at index 0
        await dataStore.addMessage(newMessage, at: 0, to: .archived)
        
        // Assert: Check if the message is in the feed
        let storedMessage = await dataStore.archive.messages.first
        let totalCount = await dataStore.archive.totalCount
        let unreadCount = await dataStore.unreadCount
        
        XCTAssertEqual(totalCount, 1, "Total count should increase by 1 after adding a message.")
        XCTAssertEqual(storedMessage?.messageId, id, "The first message in the feed should match the added message.")
        XCTAssertEqual(unreadCount, 0, "Unread count should be 0.")
    }
    
    func testAddMessageToArchive_OutOfBounds() async {
        
        let id = UUID().uuidString
        
        // Arrange: Create a new message and get initial count
        let newMessage = InboxMessage(messageId: id)
        let dataStore = await Courier.shared.newInboxModule.dataStore
        
        // Act: Add message to feed at index 0
        await dataStore.addMessage(newMessage, at: 999, to: .archived)
        
        // Assert: Check if the message is in the feed
        let storedMessage = await dataStore.archive.messages.first
        let count = await dataStore.archive.totalCount
        let unreadCount = await dataStore.unreadCount
        
        XCTAssertEqual(count, 1, "Total count should increase by 1 after adding a message.")
        XCTAssertEqual(storedMessage?.messageId, id, "The first message in the feed should match the added message.")
        XCTAssertEqual(unreadCount, 0, "Unread count should be 0.")
    }
    
}
