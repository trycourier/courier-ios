//
//  ThreadingTests.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/11/25.
//

import XCTest
@testable import Courier_iOS

extension NSLock {
    @discardableResult
    func withLock<T>(_ action: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try action()
    }
}

class ThreadingTests: XCTestCase {
    
    func testConcurrentListenerRegistrationAndRemoval() async throws {
        try await UserBuilder.authenticate()
        
        var listeners: [Any] = []
        let listenersLock = NSLock()
        
        // 1) Add 100 listeners in parallel
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    let listener = await Courier.shared.addInboxListener(onFeedChanged: { _ in })
                    listenersLock.withLock {
                        listeners.append(listener)
                    }
                }
            }
            try await group.waitForAll()
        }
        
        // 2) Remove all listeners in parallel
        try await withThrowingTaskGroup(of: Void.self) { group in
            // Safely copy and clear the array under the lock
            let currentListeners = listenersLock.withLock { () -> [Any] in
                defer { listeners.removeAll() }
                return listeners
            }
            
            for listener in currentListeners {
                group.addTask {
                    // If the type is known, cast appropriately
                    await Courier.shared.removeInboxListener(listener as! CourierInboxListener)
                }
            }
            
            try await group.waitForAll()
        }
        
        XCTAssertTrue(true)
    }
    
    func testRaceConditionOnMessageFetch() async throws {
        try await UserBuilder.authenticate()
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<50 {
                group.addTask {
                    _ = try? await Courier.shared.client?.inbox.getMessages()
                }
            }
            try await group.waitForAll()
        }
        
        XCTAssertTrue(true)
    }
    
    func testSimultaneousSignInSignOut() async throws {
        let userId = "test_user"
        let jwt = try await ExampleServer().generateJwt(
            authKey: Env.COURIER_AUTH_KEY,
            userId: userId
        )
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<50 {
                group.addTask {
                    await Courier.shared.signIn(userId: userId, accessToken: jwt)
                    await Courier.shared.signOut()
                }
            }
            try await group.waitForAll()
        }
        
        XCTAssertTrue(true)
    }
    
    func testRapidAddRemoveListenerWhileFetching() async throws {
        try await UserBuilder.authenticate()
        
        // We'll do 100 loops, each adding/removing a listener
        // and fetching messages simultaneously:
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                // 1) Add + remove a listener
                group.addTask {
                    let listener = await Courier.shared.addInboxListener(onFeedChanged: { _ in })
                    await Courier.shared.removeInboxListener(listener)
                }
                // 2) Fetch messages
                group.addTask {
                    _ = try? await Courier.shared.client?.inbox.getMessages()
                }
            }
            try await group.waitForAll()
        }
        
        XCTAssertTrue(true)
    }
    
    func testSimultaneousMessageSendAndListenerTrigger() async throws {
        try await UserBuilder.authenticate()
        
        let listener = await Courier.shared.addInboxListener(onMessageAdded: { _, _, _ in })
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<50 {
                group.addTask {
                    let _ = try? await ExampleServer.sendTest(
                        authKey: Env.COURIER_AUTH_KEY,
                        userId: Env.COURIER_USER_ID,
                        channel: "inbox"
                    )
                }
            }
            try await group.waitForAll()
        }
        
        await Courier.shared.removeInboxListener(listener)
        
        XCTAssertTrue(true)
    }
    
    func testAttemptToBreakListenerAndFetches() async throws {
        
        await Courier.shared.signOut()
        
        let jwt = try await ExampleServer().generateJwt(authKey: Env.COURIER_AUTH_KEY, userId: "example")
        
        async let task1: () = testRaces(jwt)
        async let task2: () = testRaces(jwt)
        async let task3: () = testRaces(jwt)
        async let task4: () = testRaces(jwt)
        async let task5: () = testRaces(jwt)
        
        _ = try await (task1, task2, task3, task4, task5)
        print("All tests completed.")
        
    }
    
    private func testRaces(_ jwt: String) async throws {
        
        var hold1 = true
        
        let listener1 = await Courier.shared.addInboxListener(
            onLoading: { _ in
                Task {
                    await Courier.shared.signOut()
                    hold1 = false
                }
            }
        )
        
        await Courier.shared.signIn(userId: "example", accessToken: jwt)
        
        while hold1 { /* spin */ }
        
        await Courier.shared.removeInboxListener(listener1)
        
        // Remove user on feed changed
        var hold2 = true
        
        let listener2 = await Courier.shared.addInboxListener(
            onFeedChanged: { _ in
                Task {
                    await Courier.shared.signOut()
                    hold2 = false
                }
            }
        )
        
        await Courier.shared.signIn(userId: "example", accessToken: jwt)
        
        while hold2 { /* spin */ }
        
        await Courier.shared.removeInboxListener(listener2)
        
        // Remove user on feed changed
        var hold3 = true
        
        let listener3 = await Courier.shared.addInboxListener(
            onError: { _ in
                hold3 = false
            }
        )
        
        await Courier.shared.signIn(userId: "example", accessToken: jwt)
        await Courier.shared.signOut()
        
        while hold3 { /* spin */ }
        
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
        
        _ = try await (task1, task2, task3, task4, task5)
        
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
        let onFeedChanged: (Int, Int) -> Void = { group, index in
            fetches += 1
            print("Data fetched for Group: #\(group) :: Listener #\(index)")
        }
        
        // Launch multiple tasks concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 1...5 {
                group.addTask {
                    await self.registerInboxListeners(numberOfListeners: 1, bundle: i, onFeedChanged: onFeedChanged)
                }
            }
            
            // Wait for all tasks to complete
            try await group.waitForAll()
        }
        
        try await UserBuilder.authenticate(userId: "mike")
        
        while fetches < 5 { /* spin */ }
        
        // Remove all listeners after the tasks are completed
        await Courier.shared.removeAllInboxListeners()
    }

    private func registerInboxListeners(
        numberOfListeners: Int = 10,
        bundle: Int,
        onFeedChanged: @escaping (Int, Int) -> Void
    ) async {
        await withTaskGroup(of: Void.self) { group in
            for i in 1...numberOfListeners {
                group.addTask {
                    await Courier.shared.addInboxListener(onFeedChanged: { _ in
                        onFeedChanged(bundle, i)
                    })
                }
            }
        }
    }
}
