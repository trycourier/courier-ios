//
//  InboxTests.swift
//
//  Created by https://github.com/mikemilla on 3/19/25.
//

import XCTest
@testable import Courier_iOS

/// A collection of test cases for various Inbox-related scenarios within the Courier iOS SDK.
class InboxTests: XCTestCase {
    
    // MARK: - Basic Test: Auth Error
    
    /// Demonstrates handling an authentication error scenario for the inbox.
    /// When no user is authenticated, the listener should receive an "authentication_error".
    func testAuthError() async throws {
        var hold = true
        await Courier.shared.signOut()

        let listener = await Courier.shared.addInboxListener(
            onError: { error in
                let e = error as? CourierError
                XCTAssertTrue(e?.type == "authentication_error")
                hold = false
            }
        )
        
        // Spin until the error callback is triggered
        while hold {
            // Holding...
        }
        
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - StepsTracker for Multi-Listener Tests
    
    /// An actor that tracks steps performed by multiple asynchronous events.
    /// Used to ensure specific events happen in the expected order.
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
    
    /// Tests a single listener's event sequence for loading, error, loading, feed, and archive events.
    /// 1. Signs out the user.
    /// 2. Adds one listener that tracks events into `stepsTracker`.
    /// 3. Authenticates a user, expecting certain events in a specific order.
    /// 4. Verifies the final steps sequence is as expected.
    func testSingleListener() async throws {
        let stepsTracker = StepsTracker()
        
        // Sign out any existing user
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
                // Called twice: once for feed, once for archive.
                Task { await stepsTracker.append(feed == .feed ? "feed" : "archive") }
            }
        )

        // Authenticate
        _ = try await UserBuilder.authenticate()

        // Wait until we collect 5 steps: ["loading", "error", "loading", "feed", "archive"]
        while await stepsTracker.getSteps().count < 5 {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        }

        // Remove the listener
        await Courier.shared.removeInboxListener(listener)

        // Verify steps match the expected sequence
        let finalSteps = await stepsTracker.getSteps()
        XCTAssertEqual(finalSteps, ["loading", "error", "loading", "feed", "archive"])
    }
    
    // MARK: - Multiple Listeners Test
    
    /// Tests the behavior with multiple listeners attached.
    /// 1. Signs out the user.
    /// 2. Adds three different listeners.
    /// 3. Authenticates a user, expecting each listener to get 2 completion calls (feed + archive).
    /// 4. Verifies that all expected events have arrived.
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
    
    /// Verifies pagination limits are clamped correctly by the Courier SDK.
    /// - Negative values should clamp to 1.
    /// - Excessively large values should clamp to 100.
    func testPagination() async throws {
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
    
    /// Fetches a single `InboxMessage` from the data store.
    /// - Parameters:
    ///   - messageId: The ID of the message to retrieve.
    ///   - feedType: The feed from which the message should be fetched.
    /// - Returns: The matching `InboxMessage` if it exists.
    private func getMessageFromDataStore(_ messageId: String, _ feedType: InboxMessageFeed) async -> InboxMessage {
        let dataStore = await Courier.shared.inboxModule.dataStore
        return await dataStore.getMessageById(feedType: feedType, messageId: messageId)!
    }
    
    // MARK: - Test "Open Message"
    
    /// Demonstrates opening a message, which updates its `isOpened` property to `true`.
    /// 1. Authenticates the user.
    /// 2. Sends a test message with delay and checks initial state.
    /// 3. Calls `openMessage(...)` on the SDK.
    /// 4. Verifies the message is now marked as opened.
    func testOpenMessage() async throws {
        // 1) Authenticate the user
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send a message with an intentional delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 3) Check initial state in the feed
        let state1 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertEqual(state1.isOpened, false, "Message should not be opened initially")

        // 4) Perform the "open" action
        try await Courier.shared.openMessage(message.messageId)
        
        // 5) Check final state
        let state2 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertEqual(state2.isOpened, true, "Message should now be marked as opened")
        
        // 6) Clean up listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Click Message"
    
    /// Demonstrates clicking a message. Although there's no `isClicked` property to verify,
    /// this ensures that the SDK properly tracks the click event.
    func testClickMessage() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 3) Check initial state
        let initialState = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertEqual(initialState.isRead, false, "Message should be unread at first")
        
        // 4) Perform the click action
        try await Courier.shared.clickMessage(message.messageId)
        
        // 5) There's no "clicked" property to assert, so we skip final state check
        
        // 6) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Read Message"
    
    /// Demonstrates reading a message (updating `isRead` to `true`).
    /// 1. Authenticates the user.
    /// 2. Sends a test message.
    /// 3. Verifies initial `isRead` is `false`.
    /// 4. Calls `readMessage(...)` and verifies it is now `true`.
    func testReadMessage() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 3) Check initial state
        let state1 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertFalse(state1.isRead, "Message should be unread initially")
        
        // 4) Perform read
        try await Courier.shared.readMessage(message.messageId)
        
        // 5) Verify final state
        let state2 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertTrue(state2.isRead, "Message should now be read")
        
        // 6) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Unread Message"
    
    /// Demonstrates marking a message as unread (updating `isRead` to `false`).
    /// 1. Authenticates the user.
    /// 2. Sends a test message, ensures it’s read, and then calls `unreadMessage(...)`.
    /// 3. Verifies final state is unread again.
    func testUnreadMessage() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 3) For demonstration, mark it read first
        try await Courier.shared.readMessage(message.messageId)
        
        // 4) Then unread it
        try await Courier.shared.unreadMessage(message.messageId)
        
        // 5) Verify final state
        let state = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertFalse(state.isRead, "Message should be unread again")
        
        // 6) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Tenant Message"
    
    /// Demonstrates testing messages scoped to a particular tenant.
    /// 1. Authenticates the user with a specific tenantId.
    /// 2. Sends a test message for that tenant.
    /// 3. Verifies the message is present in the feed and not archived initially.
    func testTenantMessage() async throws {
        let userId = "t1-user"
        let tenantId = "t1"
        
        // 1) Authenticate
        try await UserBuilder.authenticate(userId: userId, tenantId: tenantId)
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId, tenantId: tenantId)
        
        // 3) Check initial feed
        let state1 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertFalse(state1.isArchived, "Message should not be archived initially")
        
        // 4) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Archive Message"
    
    /// Demonstrates archiving a message.
    /// 1. Authenticates the user.
    /// 2. Sends a test message and confirms initial `isArchived` is `false`.
    /// 3. Calls `archiveMessage(...)` and verifies the message is now in the `.archive` feed.
    func testArchiveMessage() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 3) Check initial feed
        let state1 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertFalse(state1.isArchived, "Message should not be archived initially")
        
        // 4) Archive
        try await Courier.shared.archiveMessage(message.messageId)
        
        // 5) Check final state in the .archive feed
        let state2 = await getMessageFromDataStore(message.messageId, .archive)
        XCTAssertTrue(state2.isArchived, "Message should now be in the archived feed")
        
        // 6) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Read All Messages"
    
    /// Demonstrates marking all messages as read.
    /// 1. Authenticates the user.
    /// 2. Sends a test message and confirms it is unread.
    /// 3. Calls `readAllInboxMessages()` and verifies the message is now read.
    func testReadAllMessages() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        
        // 3) Initial check
        let state1 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertFalse(state1.isRead, "Message should be unread initially")
        
        // 4) Read all
        try await Courier.shared.readAllInboxMessages()
        
        // 5) Check final
        let state2 = await getMessageFromDataStore(message.messageId, .feed)
        XCTAssertTrue(state2.isRead, "Message should now be marked as read")
        
        // 6) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Shortcuts" (Open, Unread, Read, Click, Archive)
    
    /// Demonstrates a series of shortcut actions on a single message.
    /// The message is opened, marked unread, marked read, clicked, and finally archived.
    /// Each step is validated via the local data store.
    func testShortcuts() async throws {
        // 1) Authenticate
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        let messageId = message.messageId
        
        // 3) Check initial state
        let dataStore = await Courier.shared.inboxModule.dataStore
        let initialState = await dataStore.getMessageById(feedType: .feed, messageId: messageId)
        XCTAssertFalse(initialState?.isOpened ?? true, "Should not be opened initially")
        XCTAssertFalse(initialState?.isRead ?? true,   "Should not be read initially")
        XCTAssertFalse(initialState?.isArchived ?? true, "Should not be archived initially")
        
        // 4) Perform shortcut actions and verify after each step
        
        // 4a) Mark as Opened
        try await Courier.shared.openMessage(messageId)
        let state1 = await dataStore.getMessageById(feedType: .feed, messageId: messageId)
        XCTAssertTrue(state1?.isOpened ?? false, "Should now be opened")
        
        // 4b) Mark as Unread
        try await Courier.shared.unreadMessage(messageId)
        let state2 = await dataStore.getMessageById(feedType: .feed, messageId: messageId)
        XCTAssertFalse(state2?.isRead ?? true, "Should be unread")
        
        // 4c) Mark as Read
        try await Courier.shared.readMessage(messageId)
        let state3 = await dataStore.getMessageById(feedType: .feed, messageId: messageId)
        XCTAssertTrue(state3?.isRead ?? false, "Should now be read")
        
        // 4d) Mark as Clicked
        try await Courier.shared.clickMessage(messageId)
        // No property to validate for clicks, so no check here
        
        // 4e) Mark as Archived
        try await Courier.shared.archiveMessage(messageId)
        let state4 = await dataStore.getMessageById(feedType: .archive, messageId: messageId)
        XCTAssertTrue(state4?.isArchived ?? false, "Should be in the archived feed")
        
        // 5) Remove listener
        await Courier.shared.removeInboxListener(listener)
    }
    
    // MARK: - Test "Custom Message Payload"
    
    /// A sample child struct for demonstrating how custom payload data can be decoded.
    struct Child: Codable {
        let id: String?
        let name: String?
        let optional: Bool?
        let children: [Child]?
        
        /// Convenience initializer that creates a `Child` from a dictionary.
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
    
    /// Demonstrates fetching a custom message payload (a nested structure) from the data store.
    /// Logs any child structures found in `message.data`.
    func testCustomMessagePayload() async throws {
        // 1) Auth
        let userId = try await UserBuilder.authenticate()
        
        // 2) Send with delay
        let (message, listener) = try await Utils.sendInboxMessageWithConfirmation(to: userId)
        let messageId = message.messageId
        
        // 3) Fetch the message from data store, look at `message.data`
        let dataStoreMessage = await getMessageFromDataStore(messageId, .feed)
        
        // 4) Attempt to parse a nested structure
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
    
    /// Ensures that removing all inbox listeners clears out all registered listeners.
    /// 1. Authenticates the user.
    /// 2. Adds three listeners.
    /// 3. Calls `removeAllInboxListeners()` and verifies no listeners remain.
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
    
    /// Tests sending a high volume of messages (25) concurrently and verifies that
    /// all 'added' events arrive on a single listener.
    /// 1. Authenticates the user.
    /// 2. Adds a listener that increments `messageCount` each time a message is added.
    /// 3. Sends 25 messages in parallel and waits for the count to reach 25.
    /// 4. Confirms that all 25 messages have been added.
    func testSpamMessages() async throws {
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
                            // Could also do Utils.sendWithDelay if you want an explicit delay
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
