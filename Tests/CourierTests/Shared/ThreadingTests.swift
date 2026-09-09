//
//  ThreadingTests.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/11/25.
//

import Foundation
import XCTest
@testable import Courier_iOS

class ThreadingTests: XCTestCase {
    
    // MARK: - Helpers
    
    // Static so task-group closures can log without capturing the test case
    static func log(_ message: String, function: String = #function, line: Int = #line) {
        let threadDesc = Thread.isMainThread ? "Main Thread" : "Thread \(Thread.current)"
        print("[\(Date())] \(function):\(line) | \(message) | \(threadDesc)")
    }
    
    // MARK: - Tests
    
    func testConcurrentListenerRegistrationAndRemoval() async throws {
        Self.log("Starting testConcurrentListenerRegistrationAndRemoval")
        
        try await UserBuilder.authenticate()
        Self.log("Authenticated user successfully")
        
        // 1) Add 100 listeners in parallel, collecting them from the group results
        Self.log("Adding 100 listeners in parallel")
        let listeners = try await withThrowingTaskGroup(of: CourierInboxListener.self) { group in
            for i in 0..<100 {
                group.addTask {
                    Self.log("Task \(i) - adding inbox listener")
                    let listener = await Courier.shared.addInboxListener()
                    Self.log("Task \(i) - acquired listener")
                    return listener
                }
            }
            var added: [CourierInboxListener] = []
            for try await listener in group {
                added.append(listener)
            }
            return added
        }
        
        Self.log("All 100 listeners added. Now removing them in parallel.")
        
        // 2) Remove all listeners in parallel
        try await withThrowingTaskGroup(of: Void.self) { group in
            for (index, listener) in listeners.enumerated() {
                group.addTask {
                    Self.log("Removing listener #\(index)")
                    await Courier.shared.removeInboxListener(listener)
                    Self.log("Listener #\(index) removed")
                }
            }
            
            try await group.waitForAll()
        }
        
        Self.log("Finished removing all listeners")
        XCTAssertTrue(true)
    }
    
    func testRaceConditionOnMessageFetch() async throws {
        Self.log("Starting testRaceConditionOnMessageFetch")
        
        try await UserBuilder.authenticate()
        Self.log("User authenticated, starting parallel fetches")
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<50 {
                group.addTask {
                    Self.log("Task \(i) - fetching messages")
                    _ = try? await Courier.shared.client?.inbox.getMessages()
                    Self.log("Task \(i) - fetch complete")
                }
            }
            try await group.waitForAll()
        }
        
        Self.log("All fetches completed")
        XCTAssertTrue(true)
    }
    
    // This entire test is now actor-isolated to `BackgroundActor`,
    // meaning all code inside runs serially on that queue.
    func testSimultaneousSignInSignOut() async throws {
        Self.log("Starting testSimultaneousSignInSignOut (BackgroundActor)")

        let userId = "test_user"
        let jwt = try await ExampleServer.generateJwt(
            authKey: Env.COURIER_AUTH_KEY,
            userId: userId
        )

        Self.log("Generated JWT for user: \(userId)")

        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<50 {
                group.addTask {
                    // Even though we have multiple tasks in this task group,
                    // all of them are still actor-isolated to BackgroundActor,
                    // so they will be run *serially* on the same queue.
                    Self.log("Task \(i) - signing in")
                    await Courier.shared.signIn(userId: userId, accessToken: jwt)

                    let listener = await Courier.shared.addInboxListener()
                    Self.log("Task \(i) - signing out")
                    await Courier.shared.signOut()

                    listener.remove()
                    Self.log("Task \(i) - listener removed")
                }
            }
            try await group.waitForAll()
        }

        Self.log("All sign in/sign out tasks completed")
        XCTAssertTrue(true)
    }
    
    func testRapidAddRemoveListenerWhileFetching() async throws {
        Self.log("Starting testRapidAddRemoveListenerWhileFetching")
        
        try await UserBuilder.authenticate()
        Self.log("User authenticated, starting parallel add/remove + fetching")
        
        // We'll do 100 loops, each adding/removing a listener
        // and fetching messages simultaneously
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                // 1) Add + remove a listener
                group.addTask {
                    Self.log("Task \(i) - adding listener")
                    let listener = await Courier.shared.addInboxListener()
                    
                    Self.log("Task \(i) - removing listener")
                    await Courier.shared.removeInboxListener(listener)
                }
                // 2) Fetch messages
                group.addTask {
                    Self.log("Task \(i) - fetching messages")
                    _ = try? await Courier.shared.client?.inbox.getMessages()
                    Self.log("Task \(i) - fetch completed")
                }
            }
            try await group.waitForAll()
        }
        
        Self.log("All add/remove + fetch tasks completed")
        XCTAssertTrue(true)
    }
    
    func testSimultaneousMessageSendAndListenerTrigger() async throws {
        Self.log("Starting testSimultaneousMessageSendAndListenerTrigger")
        
        try await UserBuilder.authenticate()
        Self.log("User authenticated, adding inbox listener")
        
        let listener = await Courier.shared.addInboxListener(onMessageEvent: { _, _, _, event in
            if event == .added {
                Self.log("Inbox listener triggered - onMessageAdded")
            }
        })
        
        Self.log("Listener added, now sending messages in parallel")
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<50 {
                group.addTask {
                    Self.log("Task \(i) - sending test message")
                    let _ = try? await ExampleServer.sendTest(
                        authKey: Env.COURIER_AUTH_KEY,
                        userId: Env.COURIER_USER_ID,
                        channel: "inbox"
                    )
                    Self.log("Task \(i) - message sent")
                }
            }
            try await group.waitForAll()
        }
        
        Self.log("All message sends complete, removing listener")
        await Courier.shared.removeInboxListener(listener)
        
        Self.log("Listener removed")
        XCTAssertTrue(true)
    }
    
    func testSpamMessageFetch() async throws {
        Self.log("Starting testSpamMessageFetch")
        
        let userId = "mike"
        let jwt = try await ExampleServer.generateJwt(authKey: Env.COURIER_AUTH_KEY, userId: userId)
        
        Self.log("Got JWT for \(userId), launching spam tasks")
        
        async let task1: () = Self.spamGetMessages(userId: userId, jwt: jwt)
        async let task2: () = Self.spamGetMessages(userId: userId, jwt: jwt)
        async let task3: () = Self.spamGetMessages(userId: userId, jwt: jwt)
        async let task4: () = Self.spamGetMessages(userId: userId, jwt: jwt)
        async let task5: () = Self.spamGetMessages(userId: userId, jwt: jwt)
        
        _ = try await (task1, task2, task3, task4, task5)
        
        Self.log("All spam tasks completed")
    }
    
    private static func spamGetMessages(userId: String, jwt: String) async throws {
        Self.log("spamGetMessages -> signing in userId: \(userId)")
        await Courier.shared.signIn(userId: userId, accessToken: jwt)
        
        Self.log("spamGetMessages -> fetching messages")
        let _ = try await Courier.shared.client?.inbox.getMessages()
        
        Self.log("spamGetMessages -> signing out userId: \(userId)")
        await Courier.shared.signOut()
    }
    
    /// Counts listener callbacks on the main actor, where they are delivered, so no extra hop is needed.
    @MainActor final class CallbackCounter {
        var count = 0
    }
    
    actor FetchCounter {
        private var count = 0
        
        func increment() -> Int {
            count += 1
            return count
        }
        
        func getCount() -> Int {
            return count
        }
    }

    func testListenerSpam() async throws {
        Self.log("Starting testListenerSpam")
        
        await Courier.shared.signOut()
        Self.log("Signed out user to start test cleanly")
        
        let fetchCounter = FetchCounter() // Actor to track fetches safely
        
        // Define a closure for handling feed changes
        let onFeedChanged: @Sendable (Int, Int) -> Void = { group, index in
            Task {
                let count = await fetchCounter.increment()
                print("Data fetched for Group #\(group) :: Listener #\(index). (fetches total: \(count))")
            }
        }
        
        // Launch multiple tasks concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 1...5 {
                group.addTask {
                    Self.log("Registering inbox listeners for group \(i)")
                    await Self.registerInboxListeners(numberOfListeners: 1, bundle: i, onFeedChanged: onFeedChanged)
                }
            }
            
            // Wait for all tasks to complete
            try await group.waitForAll()
        }
        
        Self.log("All inbox listener tasks completed, now authenticating user 'mike'")
        try await UserBuilder.authenticate(userId: "mike")
        
        Self.log("Waiting until at least 5 feed changes have occurred")
        
        while await fetchCounter.getCount() < 5 {
            try await Task.sleep(nanoseconds: 1_000_000) // Prevents CPU spin
        }
        
        Self.log("We have at least 5 feed changes, removing all listeners now.")
        await Courier.shared.removeAllInboxListeners()
        
        Self.log("testListenerSpam completed")
    }


    private static func registerInboxListeners(
        numberOfListeners: Int = 10,
        bundle: Int,
        onFeedChanged: @escaping @Sendable (Int, Int) -> Void
    ) async {
        await withTaskGroup(of: Void.self) { group in
            for i in 1...numberOfListeners {
                group.addTask {
                    Self.log("Creating listener #\(i) in bundle #\(bundle)")
                    await Courier.shared.addInboxListener(onMessagesChanged: { _, _, _ in
                        onFeedChanged(bundle, i)
                    })
                }
            }
        }
    }
    
    func testAddRemoveListenersWhileSendingMessages() async throws {
        Self.log("Starting testAddRemoveListenersWhileSendingMessages")
        
        try await UserBuilder.authenticate()
        Self.log("User authenticated")

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<50 {
                group.addTask {
                    let listener = await Courier.shared.addInboxListener()
                    await Courier.shared.removeInboxListener(listener)
                }
                
                group.addTask {
                    _ = try? await ExampleServer.sendTest(
                        authKey: Env.COURIER_AUTH_KEY,
                        userId: Env.COURIER_USER_ID,
                        channel: "inbox"
                    )
                }
            }
            try await group.waitForAll()
        }
        
        Self.log("All listener operations and message sends completed")
        XCTAssertTrue(true)
    }
    
    func testRapidSignInSignOutDifferentUsers() async throws {
        Self.log("Starting testRapidSignInSignOutDifferentUsers")

        let userIds = (0..<10).map { "user_\($0)" }
        let jwts = try await withThrowingTaskGroup(of: (String, String).self) { group in
            for userId in userIds {
                group.addTask {
                    let jwt = try await ExampleServer.generateJwt(authKey: Env.COURIER_AUTH_KEY, userId: userId)
                    return (userId, jwt)
                }
            }
            return try await group.reduce(into: [(String, String)]()) { $0.append($1) }
        }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for (userId, jwt) in jwts {
                group.addTask {
                    await Courier.shared.signIn(userId: userId, accessToken: jwt)
                    let listener = await Courier.shared.addInboxListener()
                    await Courier.shared.signOut()
                    listener.remove()
                }
            }
            try await group.waitForAll()
        }

        Self.log("All sign-in/sign-out operations completed")
        XCTAssertTrue(true)
    }

    func testListenerCallbackUnderLoad() async throws {
        Self.log("Starting testListenerCallbackUnderLoad")

        try await UserBuilder.authenticate()
        let callbackCounter = CallbackCounter()

        let listener = await Courier.shared.addInboxListener(onMessageEvent: { message, index, feed, event in
            if event == .added {
                callbackCounter.count += 1
            }
        })

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    _ = try? await ExampleServer.sendTest(
                        authKey: Env.COURIER_AUTH_KEY,
                        userId: Env.COURIER_USER_ID,
                        channel: "inbox"
                    )
                }
            }
            try await group.waitForAll()
        }

        await Courier.shared.removeInboxListener(listener)

        let callbackCount = await callbackCounter.count
        XCTAssertGreaterThan(callbackCount, 0, "Listener should have been triggered at least once")
        Self.log("Listener callback stress test completed")
    }

    func testChaosMonkey() async throws {
        Self.log("Starting testChaosMonkey")

        let jwt = try! await ExampleServer.generateJwt(authKey: Env.COURIER_AUTH_KEY, userId: "chaos_user")

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    let operation = Int.random(in: 0..<6)
                    switch operation {
                    case 0:
                        _ = await Courier.shared.addInboxListener()
                    case 1:
                        await Courier.shared.removeAllInboxListeners()
                    case 2:
                        _ = try? await Courier.shared.client?.inbox.getMessages()
                    case 3:
                        await Courier.shared.signIn(userId: "chaos_user", accessToken: jwt)
                    case 4:
                        try await Courier.shared.setToken(for: .apn, token: "example")
                        await Courier.shared.putPushTokens()
                    case 5:
                        await Courier.shared.deletePushTokens()
                    case 6:
                        await Courier.shared.signOut()
                    default:
                        break
                    }
                }
            }
            try await group.waitForAll()
        }

        Self.log("Chaos test completed successfully")
        XCTAssertTrue(true)
        
        await Courier.shared.removeAllInboxListeners()
        
    }

    
}
