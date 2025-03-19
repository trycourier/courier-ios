//
//  InboxTests.swift
//
//
//  Created by https://github.com/mikemilla on 7/23/24.
//

import XCTest
@testable import Courier_iOS

class InboxTests: XCTestCase {
    
    // MARK: - Basic Test: Auth Error
    func testAuthError() async throws {
        /*
         Demonstrates how to test an authentication error.
         Since no user is authenticated, the listener should
         receive an "authentication_error".
         */
        
        var hold = true
        await Courier.shared.signOut()

        let listener = await Courier.shared.addInboxListener(
            onError: { error in
                let e = error as? CourierError
                XCTAssertTrue(e?.type == "authentication_error")
                hold = false
            }
        )
        
        // Spin until we get the error callback
        while hold {
            // Holding...
        }
        
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - StepsTracker for Multi-Listener Tests
    actor StepsTracker {
        private(set) var steps = [String]()
        
        func append(_ step: String) {
            steps.append(step)
            print(step)
        }
        
        func getSteps() -> [String] {
            return steps
        }
    }

    // MARK: - Single Listener Test
    func testSingleListener() async throws {
        let stepsTracker = StepsTracker()
        
        // Sign out the user
        await Courier.shared.signOut()

        // Add a listener
        let listener = await Courier.shared.addInboxListener(
            onLoading: { _ in
                Task { await stepsTracker.append("loading") }
            },
            onError: { _ in
                Task { await stepsTracker.append("error") }
            },
            onMessagesChanged: { _, _, feed in
                // This will get called twice: once for feed, once for archive.
                Task { await stepsTracker.append(feed == .feed ? "feed" : "archive") }
            }
        )

        // Authenticate
        _ = try await UserBuilder.authenticate()

        // Wait until we collect 5 steps: loading, error, loading, feed, archive
        while await stepsTracker.getSteps().count < 5 {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        }

        // Remove the listener
        await Courier.shared.removeInboxListener(listener)

        // Verify steps match expected sequence
        let finalSteps = await stepsTracker.getSteps()
        XCTAssertEqual(finalSteps, ["loading", "error", "loading", "feed", "archive"])
    }
    
    // MARK: - Multiple Listeners Test
    func testMultipleListeners() async throws {
        let stepsTracker = StepsTracker()

        // Sign out the user
        await Courier.shared.signOut()

        // Add several listeners
        let listener1 = await Courier.shared.addInboxListener(
            onLoading: { _ in Task { await stepsTracker.append("loading 1") } },
            onError:   { _ in Task { await stepsTracker.append("error 1") } },
            onMessagesChanged: { _, _, _ in Task { await stepsTracker.append("complete 1") } }
        )

        let listener2 = await Courier.shared.addInboxListener(
            onLoading: { _ in Task { await stepsTracker.append("loading 2") } },
            onError:   { _ in Task { await stepsTracker.append("error 2") } },
            onMessagesChanged: { _, _, _ in Task { await stepsTracker.append("complete 2") } }
        )

        let listener3 = await Courier.shared.addInboxListener(
            onLoading: { _ in Task { await stepsTracker.append("loading 3") } },
            onError:   { _ in Task { await stepsTracker.append("error 3") } },
            onMessagesChanged: { _, _, _ in Task { await stepsTracker.append("complete 3") } }
        )

        // Authenticate the user
        _ = try await UserBuilder.authenticate()

        // We expect each listener to get "complete" for feed + archive => 2 each => 6 total
        while true {
            let completeCount = await stepsTracker.getSteps()
                .filter { $0.contains("complete") }
                .count
            if completeCount == 6 {
                break
            }
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        }

        // Remove them
        await Courier.shared.removeInboxListener(listener1)
        await Courier.shared.removeInboxListener(listener2)
        await Courier.shared.removeInboxListener(listener3)

        let finalSteps = await stepsTracker.getSteps()
        print("Final steps:", finalSteps)
    }
    
    // MARK: - Pagination Limit Test
    func testPagination() async throws {
        /*
         Setting out-of-range pagination limits in the Courier SDK
         forces them to clamp. Negative => 1, large => 100, etc.
         */
        
        await Courier.shared.setPaginationLimit(-100)
        let inboxPaginationLimit1 = await Courier.shared.inboxPaginationLimit == 1
        XCTAssertTrue(inboxPaginationLimit1)

        await Courier.shared.setPaginationLimit(1000)
        let inboxPaginationLimit2 = await Courier.shared.inboxPaginationLimit == 100
        XCTAssertTrue(inboxPaginationLimit2)

        // Now set a normal value
        await Courier.shared.setPaginationLimit(32)
    }
    
    // MARK: - Helper to fetch a Message from the DataStore
    private func getMessageFromDataStore(_ messageId: String, _ feedType: InboxMessageFeed) async -> InboxMessage {
        let dataStore = await Courier.shared.inboxModule.dataStore
        return await dataStore.getMessageById(feedType: feedType, messageId: messageId)!
    }
    
    // MARK: - Test "Open Message" (Example Reference)
    func testOpenMessage() async throws {
        // 1) Authenticate the user
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send a message with an intentional delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 4) Check initial state in the feed
        let state1 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertEqual(state1.isOpened, false, "Message should not be opened initially")

        // 5) Perform the "open" action
        try await Courier.shared.openMessage(message.messageId)
        
        // 6) Check final state
        let state2 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertEqual(state2.isOpened, true, "Message should now be marked as opened")
        
        // 7) Clean up listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Click Message"
    func testClickMessage() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 4) Check initial state
        let initialState = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertEqual(initialState.isRead, false, "Message should be unread at first")
        
        // 5) Perform the click action
        try await Courier.shared.clickMessage(message.messageId)
        
        // 6) There's no "clicked" property to assert, so we skip final state check
        
        // 7) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Read Message"
    func testReadMessage() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 4) Check initial state
        let state1 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertFalse(state1.isRead, "Message should be unread initially")
        
        // 5) Perform read
        try await Courier.shared.readMessage(message.messageId)
        
        // 6) Verify final state
        let state2 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertTrue(state2.isRead, "Message should now be read")
        
        // 7) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Unread Message"
    func testUnreadMessage() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 4) For demonstration, mark it read first
        try await Courier.shared.readMessage(message.messageId)
        
        // 5) Then unread it
        try await Courier.shared.unreadMessage(message.messageId)
        
        // 6) Verify final state
        let state = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertFalse(state.isRead, "Message should be unread again")
        
        // 7) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Tenant Message"
    func testTenantMessage() async throws {
        
        let userId = "t1-user"
        let tenantId = "t1"
        
        // 1) Authenticate
        try await UserBuilder.authenticate(userId: userId, tenantId: tenantId)
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId, tenantId: tenantId)
        
        // 4) Check initial feed
        let state1 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertFalse(state1.isArchived, "Message should not be archived initially")
        
        // 7) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Archive Message"
    func testArchiveMessage() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 4) Check initial feed
        let state1 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertFalse(state1.isArchived, "Message should not be archived initially")
        
        // 5) Archive
        try await Courier.shared.archiveMessage(message.messageId)
        
        // 6) Check final state in the .archive feed
        let state2 = await getMessageFromDataStore(message.messageId, .archive)
        XCTAssertTrue(state2.isArchived, "Message should now be in the archived feed")
        
        // 7) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Read All Messages"
    func testReadAllMessages() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 4) Initial check
        let state1 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertFalse(state1.isRead, "Message should be unread initially")
        
        // 5) Read all
        try await Courier.shared.readAllInboxMessages()
        
        // 6) Check final
        let state2 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertTrue(state2.isRead, "Message should now be marked as read")
        
        // 7) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Shortcuts" (Open, Unread, Read, Click, Archive)
    func testShortcuts() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        let messageId = message.messageId
        
        // 4) Check initial state
        let dataStore = await Courier.shared.inboxModule.dataStore
        let initialState = await dataStore.getMessageById(feedType: .feed, messageId: messageId)
        XCTAssertFalse(initialState?.isOpened ?? true, "Should not be opened initially")
        XCTAssertFalse(initialState?.isRead ?? true,   "Should not be read initially")
        XCTAssertFalse(initialState?.isArchived ?? true, "Should not be archived initially")
        
        // 5a) Mark as Opened
        try await Courier.shared.openMessage(messageId)
        let state1 = await dataStore.getMessageById(feedType: .feed, messageId: messageId)
        XCTAssertTrue(state1?.isOpened ?? false, "Should now be opened")
        
        // 5b) Mark as Unread
        try await Courier.shared.unreadMessage(messageId)
        let state2 = await dataStore.getMessageById(feedType: .feed, messageId: messageId)
        XCTAssertFalse(state2?.isRead ?? true, "Should be unread")
        
        // 5c) Mark as Read
        try await Courier.shared.readMessage(messageId)
        let state3 = await dataStore.getMessageById(feedType: .feed, messageId: messageId)
        XCTAssertTrue(state3?.isRead ?? false, "Should now be read")
        
        // 5d) Mark as Clicked (no property to assert, so we skip final check)
        try await Courier.shared.clickMessage(messageId)
        
        // 5e) Mark as Archived
        try await Courier.shared.archiveMessage(messageId)
        let state4 = await dataStore.getMessageById(feedType: .archive, messageId: messageId)
        XCTAssertTrue(state4?.isArchived ?? false, "Should be in the archived feed")
        
        // 6) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Custom Message Payload"
    struct Child: Codable {
        let id: String?
        let name: String?
        let optional: Bool?
        let children: [Child]?
        
        init?(dictionary: [String: Any]) {
            id = dictionary["id"] as? String
            name = dictionary["name"] as? String
            optional = dictionary["optional"] as? Bool
            if let arr = dictionary["children"] as? [[String: Any]] {
                children = arr.compactMap { Child(dictionary: $0) }
            } else {
                children = nil
            }
        }
    }
    
    func testCustomMessagePayload() async throws {
        // 1) Auth
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        let messageId = message.messageId
        
        // 4) Fetch the message from data store, look at `message.data`
        let dataStoreMessage = await getMessageFromDataStore(messageId, .feed)
        
        if let childrenData = dataStoreMessage.data?["children"] as? [[String: Any]] {
            let children = childrenData.compactMap { Child(dictionary: $0) }
            children.forEach { child in
                print(child.id ?? "No id found")
                print(child.name ?? "No name found")
                print(child.optional ?? "No optional found")
                print(child.children?.count ?? "No subchildren found")
                print("=======")
            }
        }
        
        // 5) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test Removing All Listeners
    func testRemoveAllInboxListeners() async throws {
        try await UserBuilder.authenticate()
        
        await Courier.shared.addInboxListener()
        await Courier.shared.addInboxListener()
        await Courier.shared.addInboxListener()
        
        let listeners1 = await Courier.shared.inboxModule.inboxListeners
        XCTAssertEqual(listeners1.count, 3, "Should have 3 listeners")
        
        await Courier.shared.removeAllInboxListeners()
        let listeners2 = await Courier.shared.inboxModule.inboxListeners
        XCTAssertEqual(listeners2.count, 0, "Should have removed all listeners")
    }
    
    // MARK: - Test "Spam" Multiple Messages
    func testSpamMessages() async throws {
        /*
         Sends 25 messages concurrently, verifying that all
         'added' events arrive via a single listener.
        */
        
        let userId = try await UserBuilder.authenticate()
        let count = 25
        var messageCount = 0
        
        var listener: CourierInboxListener? = nil

        // Wait for all messages to be received
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            Task {
                // Add a listener that increments messageCount
                listener = await Courier.shared.addInboxListener(onMessageEvent: { _, _, _, event in
                    if event == .added {
                        messageCount += 1
                        print("Message Count updated: \(messageCount)")

                        // Resume once we've seen all 25
                        if messageCount == count {
                            continuation.resume()
                        }
                    }
                })
                
                // Send all messages in parallel
                try await withThrowingTaskGroup(of: Void.self) { group in
                    for _ in 1...count {
                        group.addTask {
                            // Could also do Utils.sendWithDelay if you want to forcibly delay
                            _ = try await Utils.sendMessageWithDelay(to: userId, delay: 0)
                        }
                    }
                    try await group.waitForAll()
                    print("All message sends have completed")
                }
            }
        }
        
        // Clean up
        if let listener = listener {
            await Courier.shared.removeInboxListener(listener)
        }

        // Final assert: all 25 messages should have arrived
        XCTAssertEqual(messageCount, count)
    }
}
