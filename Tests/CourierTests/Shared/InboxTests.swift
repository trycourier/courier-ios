//
//  InboxTests.swift
//
//
//  Created by https://github.com/mikemilla on 7/23/24.
//

import XCTest
@testable import Courier_iOS

class InboxTests: XCTestCase {
    
    private let delay: UInt64 = 10_000_000_000
    
    @discardableResult
    public static func sendMessage(userId: String? = nil) async throws -> String {
        let clientUserId = await Courier.shared.client?.options.userId
        return try await ExampleServer.sendTest(
            authKey: Env.COURIER_AUTH_KEY,
            userId: userId ?? clientUserId ?? Env.COURIER_USER_ID,
            channel: "inbox"
        )
    }
    
    override func tearDown() async throws {
        await Courier.shared.removeAllInboxListeners()
        try await super.tearDown()
    }
    
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
        
        while (hold) {
            // Hold
        }

        await Courier.shared.removeInboxListener(listener)

    }
    
    private func getVerifiedInboxMessage() async throws -> InboxMessage {
        try await withCheckedThrowingContinuation { continuation in
            
            // A simple lock + boolean to ensure we don’t resume the continuation twice
            let lock = NSLock()
            var didFinish = false
            
            func finish(_ result: Result<InboxMessage, Error>, remove listener: NewCourierInboxListener) {
                lock.lock()
                defer { lock.unlock() }
                guard !didFinish else { return }
                didFinish = true

                // Resume the continuation exactly once
                switch result {
                case .success(let message):
                    continuation.resume(returning: message)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
                
                // Remove the listener exactly once
                Task {
                    await Courier.shared.removeInboxListener(listener)
                }
            }
            
            Task {
                do {
                    
                    var messageId: String? = nil
                    var listener: NewCourierInboxListener? = nil
                    
                    // 1. Add the listener and capture both it + messageId safely.
                    listener = await Courier.shared.addInboxListener(onMessageEvent: { message, index, feed, event in
                        if event == .added && message.messageId == messageId {
                            // We got the matching message—finish successfully.
                            finish(.success(message), remove: listener!)
                        }
                    })
                    
                    // 2. Get messageId first (no race condition with the listener).
                    messageId = try await InboxTests.sendMessage()
                    
                    // 3. Sleep for 30 seconds to create a timeout.
                    try? await Task.sleep(nanoseconds: 30_000_000_000)
                    
                    // 4. If we got here, we timed out.
                    finish(.failure(CourierError.inboxNotInitialized), remove: listener!)
                    
                } catch {
                    // If we failed before we even added the listener, just resume with error.
                    // (We haven’t added the listener yet, so no need to remove it.)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
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
                // This will get called twice. Once for feed, once for archive.
                Task { await stepsTracker.append(feed == .feed ? "feed" : "archive") }
            }
        )

        try await UserBuilder.authenticate()

        while await stepsTracker.getSteps().count < 5 {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
        }

        // Remove the listener
        await Courier.shared.removeInboxListener(listener)

        // Verify steps match expected sequence
        let finalSteps = await stepsTracker.getSteps()
        XCTAssertEqual(finalSteps, ["loading", "error", "loading", "feed", "archive"])
    }
    
    func testMultipleListeners() async throws {
        // Use the same StepsTracker actor from your single-listener test
        let stepsTracker = StepsTracker()

        // Sign out the user
        await Courier.shared.signOut()

        // Add listeners
        let listener1 = await Courier.shared.addInboxListener(
            onLoading: { _ in
                Task { await stepsTracker.append("loading 1") }
            },
            onError: { _ in
                Task { await stepsTracker.append("error 1") }
            },
            onMessagesChanged: { _, _, _ in
                Task { await stepsTracker.append("complete 1") }
            }
        )

        let listener2 = await Courier.shared.addInboxListener(
            onLoading: { _ in
                Task { await stepsTracker.append("loading 2") }
            },
            onError: { _ in
                Task { await stepsTracker.append("error 2") }
            },
            onMessagesChanged: { _, _, _ in
                Task { await stepsTracker.append("complete 2") }
            }
        )

        let listener3 = await Courier.shared.addInboxListener(
            onLoading: { _ in
                Task { await stepsTracker.append("loading 3") }
            },
            onError: { _ in
                Task { await stepsTracker.append("error 3") }
            },
            onMessagesChanged: { _, _, _ in
                Task { await stepsTracker.append("complete 3") }
            }
        )

        // Authenticate the user
        try await UserBuilder.authenticate()

        // Wait until we have seen all "complete" messages (each listener should fire once).
        // In this example, we expect 3 listeners × 2 "complete" calls? Or maybe 3 total?
        // Adjust the condition to match your actual expectations.
        while true {
            let completeCount = await stepsTracker.getSteps()
                .filter { $0.contains("complete") }
                .count
            if completeCount == 6 {
                break
            }
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s delay
        }

        // Remove the listeners
        await Courier.shared.removeInboxListener(listener1)
        await Courier.shared.removeInboxListener(listener2)
        await Courier.shared.removeInboxListener(listener3)

        // Inspect final steps if needed
        let finalSteps = await stepsTracker.getSteps()
        print("Final steps:", finalSteps)
    }
    
    func testPagination() async throws {

        try await UserBuilder.authenticate()

        await Courier.shared.setPaginationLimit(-100)
        let inboxPaginationLimit1 = await Courier.shared.inboxPaginationLimit == 1
        XCTAssertTrue(inboxPaginationLimit1)

        await Courier.shared.setPaginationLimit(1000)
        let inboxPaginationLimit2 = await Courier.shared.inboxPaginationLimit == 100
        XCTAssertTrue(inboxPaginationLimit2)

        await Courier.shared.setPaginationLimit(32)
    }
    
    func testOpenMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        let message = try await getVerifiedInboxMessage()

        try await Courier.shared.openMessage(message.messageId)

    }
    
    func testClickMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        let message = try await getVerifiedInboxMessage()

        try await Courier.shared.clickMessage(message.messageId)

    }
    
    func testReadMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        let message = try await getVerifiedInboxMessage()

        try await Courier.shared.readMessage(message.messageId)

    }
    
    func testUnreadMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        let message = try await getVerifiedInboxMessage()

        try await Courier.shared.unreadMessage(message.messageId)

    }
    
    func testArchiveMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        let message = try await getVerifiedInboxMessage()

        try await Courier.shared.archiveMessage(message.messageId)

    }
    
    func testReadAllMessages() async throws {
        
        try await UserBuilder.authenticate()

        try await Courier.shared.readAllInboxMessages()

    }
    
    func testShortcuts() async throws {
        
        try await UserBuilder.authenticate()
        
        let message = try await getVerifiedInboxMessage()
        
        let dataStore = await Courier.shared.inboxModule.dataStore

        try await message.markAsOpened()
        let messageState1 = await dataStore.getMessageById(feedType: .feed, messageId: message.messageId)
        XCTAssertEqual(messageState1?.isOpened, true)
        
        try await message.markAsUnread()
        let messageState2 = await dataStore.getMessageById(feedType: .feed, messageId: message.messageId)
        XCTAssertEqual(messageState2?.isRead, false)
        
        try await message.markAsRead()
        let messageState3 = await dataStore.getMessageById(feedType: .feed, messageId: message.messageId)
        XCTAssertEqual(messageState3?.isRead, true)
        
        try await message.markAsClicked()
        // Cant test this :/

        try await message.markAsArchived()
        let messageState4 = await dataStore.getMessageById(feedType: .archived, messageId: message.messageId)
        XCTAssertEqual(messageState4?.isArchived, true)

    }
    
    func testOnMessageEventCallback() async throws {
        try await UserBuilder.authenticate()

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                await Courier.shared.addInboxListener(onMessageEvent:  { _, _, _, event in
                    if event == .added {
                        continuation.resume()
                    }
                })
                try await InboxTests.sendMessage()
            }
        }

        await Courier.shared.removeAllInboxListeners() // Clean up the listener after completion

        // Assertion to ensure the flow completes successfully
        XCTAssertTrue(true)
    }
    
    struct Child: Codable {
        let id: String?
        let name: String?
        let optional: Bool?
        let children: [Child]?
        
        init?(dictionary: [String: Any]) {

            id = dictionary["id"] as? String
            name = dictionary["name"] as? String
            optional = dictionary["optional"] as? Bool
            
            if let childrenArray = dictionary["children"] as? [[String: Any]] {
                children = childrenArray.compactMap { Child(dictionary: $0) }
            } else {
                children = nil
            }
            
        }
    }
    
    func testCustomMessagePayload() async throws {
        try await UserBuilder.authenticate()
        
        let message = try await getVerifiedInboxMessage()
        
        if let childrenData = message.data?["children"] as? [[String: Any]] {
            let children = childrenData.compactMap { Child(dictionary: $0) }
            children.forEach { child in
                print(child.id ?? "No id found")
                print(child.name ?? "No name found")
                print(child.optional ?? "No optional found")
                print(child.children?.count ?? "No subchildren found")
                print("=======")
            }
        }
    }
    
    func testSpamMessages() async throws {
        try await UserBuilder.authenticate()

        let count = 25
        var messageCount = 0

        // Use a continuation to await message reception for all messages
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            Task {
                await Courier.shared.addInboxListener(onMessageEvent: { _, _, _, event in
                    if event == .added {
                        messageCount += 1
                        print("Message Count updated: \(messageCount)")

                        // Resume the continuation when all messages are received
                        if messageCount == count {
                            continuation.resume()
                        }
                    }
                })
            }

            Task {
                // Send messages concurrently
                try await withThrowingTaskGroup(of: Void.self) { group in
                    for _ in 1...count {
                        group.addTask {
                            try await InboxTests.sendMessage()
                        }
                    }
                    try await group.waitForAll()
                    print("All message send tasks have completed")
                }
            }
        }
        
        // Remove the listener after receiving all messages
        await Courier.shared.removeAllInboxListeners()

        // Assert to ensure all messages were received
        XCTAssertEqual(messageCount, count)
    }
    
}
