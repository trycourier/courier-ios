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
    private func sendMessage(userId: String? = nil) async throws -> String {
        let clientUserId = await Courier.shared.client?.options.userId
        return try await ExampleServer.sendTest(
            authKey: Env.COURIER_AUTH_KEY,
            userId: userId ?? clientUserId ?? Env.COURIER_USER_ID,
            channel: "inbox"
        )
    }
    
    override class func setUp() {
        Task {
            await Courier.shared.removeAllInboxListeners()
        }
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
    
    private func getVerifiedInboxMessage() async throws -> String {

        let messageId = try await sendMessage()

        try? await Task.sleep(nanoseconds: delay)
 
        return messageId

    }
    
    func testSingleListener() async throws {
        var steps = [String]()
        let stepsLock = DispatchQueue(label: "steps.lock")
        
        // Sign out the user
        await Courier.shared.signOut()

        // Add a listener
        let listener = await Courier.shared.addInboxListener(
            onLoading: {
                stepsLock.sync {
                    steps.append("loading")
                }
            },
            onError: { error in
                Task {
                    stepsLock.sync {
                        steps.append("error")
                    }
                }
            },
            onFeedChanged: { set in
                stepsLock.sync {
                    steps.append("complete")
                }
            }
        )
        
        try await UserBuilder.authenticate()

        // Wait until all expected steps are recorded
        while true {
            let currentSteps = stepsLock.sync { steps }
            if currentSteps == ["loading", "error", "loading", "complete"] {
                break
            }
            await Task.yield() // Yield to allow other tasks to progress
        }

        // Remove the listener
        await Courier.shared.removeInboxListener(listener)

        // Verify steps match expected sequence
        XCTAssertTrue(stepsLock.sync { steps } == ["loading", "error", "loading", "complete"])
    }
    
    func testMultipleListeners() async throws {
        var steps = [String]()
        let stepsLock = DispatchQueue(label: "steps.lock") // To synchronize access

        // Sign out the user
        await Courier.shared.signOut()

        // Add listeners
        let listener1 = await Courier.shared.addInboxListener(
            onLoading: {
                stepsLock.sync {
                    steps.append("loading 1")
                }
            },
            onError: { error in
                stepsLock.sync {
                    steps.append("error 1")
                }
            },
            onFeedChanged: { inbox in
                stepsLock.sync {
                    steps.append("complete 1")
                }
            }
        )

        let listener2 = await Courier.shared.addInboxListener(
            onLoading: {
                stepsLock.sync {
                    steps.append("loading 2")
                }
            },
            onError: { error in
                stepsLock.sync {
                    steps.append("error 2")
                }
            },
            onFeedChanged: { inbox in
                stepsLock.sync {
                    steps.append("complete 2")
                }
            }
        )

        let listener3 = await Courier.shared.addInboxListener(
            onLoading: {
                stepsLock.sync {
                    steps.append("loading 3")
                }
            },
            onError: { error in
                stepsLock.sync {
                    steps.append("error 3")
                }
            },
            onFeedChanged: { inbox in
                stepsLock.sync {
                    steps.append("complete 3")
                }
            }
        )
        
        try await UserBuilder.authenticate()

        // Wait for all "complete" messages to appear
        while true {
            let completeCount = stepsLock.sync {
                steps.filter { $0.contains("complete") }.count
            }
            if completeCount >= 3 {
                break
            }
            await Task.yield() // Allow other async tasks to progress
        }

        // Cleanup: remove listeners
        await Courier.shared.removeInboxListener(listener1)
        await Courier.shared.removeInboxListener(listener2)
        await Courier.shared.removeInboxListener(listener3)
    }
    
    func testPagination() async throws {

        var hold = true

        try await UserBuilder.authenticate()

        await Courier.shared.setPaginationLimit(-100)
        let inboxPaginationLimit1 = await Courier.shared.inboxPaginationLimit == 1
        XCTAssertTrue(inboxPaginationLimit1)

        await Courier.shared.setPaginationLimit(1000)
        let inboxPaginationLimit2 = await Courier.shared.inboxPaginationLimit == 100
        XCTAssertTrue(inboxPaginationLimit2)

        let count = 5

        var messageCount = 0
        await Courier.shared.addInboxListener(onMessageAdded: { feed, index, message in
            messageCount += 1
            hold = messageCount < count
        })

        // Register some random listeners
        await Courier.shared.addInboxListener()
        await Courier.shared.addInboxListener()
        await Courier.shared.addInboxListener()
        await Courier.shared.addInboxListener()
        await Courier.shared.addInboxListener()

        // Send some messages
        for _ in 1...count {
            try await sendMessage()
        }

        try? await Task.sleep(nanoseconds: delay)

        while (hold) {
            // Hold
        }

        await Courier.shared.removeAllInboxListeners()
        await Courier.shared.setPaginationLimit(32)

    }
    
    func testOpenMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        let messageId = try await getVerifiedInboxMessage()

        try await Courier.shared.openMessage(messageId)

    }
    
    func testClickMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        let messageId = try await getVerifiedInboxMessage()

        try await Courier.shared.clickMessage(messageId)

    }
    
    func testReadMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        let messageId = try await getVerifiedInboxMessage()

        try await Courier.shared.readMessage(messageId)

    }
    
    func testUnreadMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        let messageId = try await getVerifiedInboxMessage()

        try await Courier.shared.unreadMessage(messageId)

    }
    
    func testArchiveMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        let messageId = try await getVerifiedInboxMessage()

        try await Courier.shared.archiveMessage(messageId)

    }
    
    func testReadAllMessages() async throws {
        
        try await UserBuilder.authenticate()

        try await Courier.shared.readAllInboxMessages()

    }
    
    func testShortcuts() async throws {
        
        try await UserBuilder.authenticate()
        
        let messageId = try await getVerifiedInboxMessage()
        
        let message = InboxMessage(
            messageId: messageId
        )

        try await message.markAsOpened()
        try await message.markAsUnread()
        try await message.markAsRead()
        try await message.markAsClicked()
        try await message.markAsArchived()

    }
    
    func testAddMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        var hold = true
        let listener = await Courier.shared.addInboxListener(onMessageAdded: { feed, message, index in
            hold = false
        })
        
        try await sendMessage()
        
        while (hold) {
            // Wait
        }
        
        await Courier.shared.removeInboxListener(listener)
        
    }
    
    func testSpamMessages() async throws {
        
        try await UserBuilder.authenticate()
        
        let count = 25
        var hold = true
        
        var messageCount = 0
        let listener = await Courier.shared.addInboxListener(onMessageAdded: { feed, message, index in
            messageCount += 1
            hold = messageCount != count
            print("Message Counted updated: \(messageCount)")
        })
        
        try await withThrowingTaskGroup(of: String.self) { group in
            
            for _ in 1...25 {
                group.addTask { [self] in
                    try await sendMessage()
                    return ""
                }
            }

            try await group.waitForAll()
            print("All tasks have completed")
            
        }
        
        while (hold) {
            // Wait
        }
        
        await Courier.shared.removeInboxListener(listener)
        
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
    
    func testSingleMessage() async throws {
        
        try await UserBuilder.authenticate()
        
        var hold = true
        
        let listener = await Courier.shared.addInboxListener(onMessageAdded: { feed, index, message in
            
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
            
            hold = false
            
        })
        
        try await sendMessage()
        
        while (hold) {
            // Wait
        }
        
        await Courier.shared.removeInboxListener(listener)
        
    }
    
    func testAttemptToBreakListenerAndFetches() async throws {
        
        await Courier.shared.signOut()
        
        let jwt = try await ExampleServer().generateJwt(authKey: Env.COURIER_AUTH_KEY, userId: "example")
        
        async let task1: () = testRaces(jwt)
        async let task2: () = testRaces(jwt)
        async let task3: () = testRaces(jwt)
        async let task4: () = testRaces(jwt)
        async let task5: () = testRaces(jwt)
        
        // Await all tasks to finish
        let _ = try await (task1, task2, task3, task4, task5)
        print("All tests completed.")
        
    }
    
    private func testRaces(_ jwt: String) async throws {
        
        var hold1 = true
        
        let listener1 = await Courier.shared.addInboxListener(
            onLoading: {
                Task {
                    await Courier.shared.signOut()
                    hold1 = false
                }
            }
        )
        
        await Courier.shared.signIn(userId: "example", accessToken: jwt)
        
        while (hold1) {}
        
        await Courier.shared.removeInboxListener(listener1)
        
        // Remove user on feed changed
        
        var hold2 = true
        
        let listener2 = await Courier.shared.addInboxListener(
            onFeedChanged: { messageSet in
                Task {
                    await Courier.shared.signOut()
                    hold2 = false
                }
            }
        )
        
        await Courier.shared.signIn(userId: "example", accessToken: jwt)
        
        while (hold2) {}
        
        await Courier.shared.removeInboxListener(listener2)
        
        // Remove user on feed changed
        
        var hold3 = true
        
        let listener3 = await Courier.shared.addInboxListener(
            onError: { error in
                hold3 = false
            }
        )
        
        await Courier.shared.signIn(userId: "example", accessToken: jwt)
        await Courier.shared.signOut()
        
        while (hold3) {}
        
        await Courier.shared.removeInboxListener(listener3)
        
    }
    
    func testSpamMessageFetch() async throws {
        
        let userId = "mike"
        let jwt = try await ExampleServer().generateJwt(authKey: Env.COURIER_AUTH_KEY, userId: userId)
        
        async let task1: () = spamGetMessages(userId: userId, jwt: jwt)
        async let task2: () = spamGetMessages(userId: userId, jwt: jwt)
        async let task3: () = spamGetMessages(userId: userId, jwt: jwt)
        async let task4: () = spamGetMessages(userId: userId, jwt: jwt)
        async let task5: () = spamGetMessages(userId: userId, jwt: jwt)
        
        // Await all tasks to finish
        let _ = try await (task1, task2, task3, task4, task5)
        
    }
    
    private func spamGetMessages(userId: String, jwt: String) async throws {
        await Courier.shared.signIn(userId: userId, accessToken: jwt)
        let _ = try await Courier.shared.client?.inbox.getMessages()
        await Courier.shared.signOut()
    }
    
    func testListenerSpam() async throws {
        
        await Courier.shared.signOut()
        
        var fetches = 0
        
        // Define a closure for handling feed changes
        let onFeedChanged: (Int, InboxMessageSet) -> Void = { listener, set in
            fetches += 1
            print("Listener: \(listener), Feed fetched: \(fetches). Message Count: \(set.totalCount)")
        }
        
        // Launch multiple tasks concurrently using Task Group for better scalability
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 1...5 { // 5 listeners as per the original tasks
                group.addTask {
                    await self.registerInboxListeners(numberOfListeners: 10, onFeedChanged: onFeedChanged)
                }
            }
            
            // Wait for all tasks to complete
            try await group.waitForAll()
        }
        
        try await UserBuilder.authenticate(userId: "mike")
        
        while (fetches < 50) {
            
        }
        
        // Remove all listeners after the tasks are completed
        await Courier.shared.removeAllInboxListeners()
        
    }

    private func registerInboxListeners(numberOfListeners: Int = 10, onFeedChanged: @escaping (Int, InboxMessageSet) -> Void) async {
        await withTaskGroup(of: Void.self) { group in
            for i in 1...numberOfListeners {
                group.addTask {
                    await Courier.shared.addInboxListener(onFeedChanged: { set in
                        onFeedChanged(i, set)
                    })
                }
            }
        }
    }
    
}
