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
        return try await ExampleServer.sendTest(
            authKey: Env.COURIER_AUTH_KEY,
            userId: userId ?? Courier.shared.client?.options.userId ?? Env.COURIER_USER_ID,
            channel: "inbox"
        )
    }
    
    func testAuthError() async throws {
        
        var hold = true
        
        await Courier.shared.signOut()

        let listener = Courier.shared.addInboxListener(
            onError: { error in
                
                let e = error as? CourierError
                XCTAssertTrue(e?.type == "authentication_error")
                
                hold = false
                
            }
        )
        
        while (hold) {
            // Hold
        }

        listener.remove()

    }
    
    private func getVerifiedInboxMessage() async throws -> InboxMessage {

        let messageId = try await sendMessage()

        try? await Task.sleep(nanoseconds: delay)
        
        let res = try await Courier.shared.client?.inbox.getMessages()

        let message = res?.data?.messages?.nodes?.first

        XCTAssertNotNil(message, "Message Exists")
        XCTAssertTrue(message!.messageId == messageId)
 
        return message!

    }
    
    // Should fail first, the sign user in, then fetch all messages
    func testSingleListener() async throws {
        
        var hold = true
        
        await Courier.shared.signOut()

        let listener = Courier.shared.addInboxListener(
            onInitialLoad: {
                print("Loading")
            },
            onError: { error in
                Task {
                    try await UserBuilder.authenticate()
                }
            },
            onMessagesChanged: { messages, unreadCount, totalCount, canPaginate in
                hold = false
            }
        )
        
        while (hold) {
            // Hold
        }

        listener.remove()

    }
    
    // Should fail first, the sign user in, then fetch all messages
    func testMultipleListeners() async throws {
        
        var hold1 = true
        var hold2 = true
        var hold3 = true
        
        await Courier.shared.signOut()

        let listener1 = Courier.shared.addInboxListener(
            onInitialLoad: {
                print("Loading")
            },
            onError: { error in
                Task {
                    try await UserBuilder.authenticate()
                }
            },
            onMessagesChanged: { messages, unreadCount, totalCount, canPaginate in
                hold1 = false
            }
        )
        
        let listener2 = Courier.shared.addInboxListener(
            onMessagesChanged: { messages, unreadCount, totalCount, canPaginate in
                hold2 = false
            }
        )
        
        let listener3 = Courier.shared.addInboxListener(
            onMessagesChanged: { messages, unreadCount, totalCount, canPaginate in
                hold3 = false
            }
        )
        
        while (hold1 || hold2 || hold3) {
            // Hold
        }

        listener1.remove()
        listener2.remove()
        listener3.remove()

    }
    
    func testPagination() async throws {
        
        var hold = true
        
        try await UserBuilder.authenticate()
        
        Courier.shared.inboxPaginationLimit = -100
        XCTAssertTrue(Courier.shared.inboxPaginationLimit == 1)
        
        Courier.shared.inboxPaginationLimit = 1000
        XCTAssertTrue(Courier.shared.inboxPaginationLimit == 100)
        
        let count = 5
        
        Courier.shared.addInboxListener(onMessagesChanged: { messages, unreadCount, totalCount, canPaginate in
            print("Messages Updated: \(messages.count)")
            hold = messages.count < count
        })
        
        // Register some random listeners
        Courier.shared.addInboxListener()
        Courier.shared.addInboxListener()
        Courier.shared.addInboxListener()
        Courier.shared.addInboxListener()
        Courier.shared.addInboxListener()
        
        // Send some messages
        for _ in 1...count {
            try await sendMessage()
        }
        
        try? await Task.sleep(nanoseconds: delay)
        
        while (hold) {
            // Hold
        }

        Courier.shared.removeAllInboxListeners()
        
        Courier.shared.inboxPaginationLimit = 32
        XCTAssertTrue(Courier.shared.inboxPaginationLimit == 32)

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

        try await message.markAsOpened()
        try await message.markAsUnread()
        try await message.markAsRead()
        try await message.markAsClicked()
        try await message.markAsArchived()

    }
    
    func testSpamMessages() async throws {
        
        try await UserBuilder.authenticate()
        
        let count = 25
        var hold = true
        
        let listener = Courier.shared.addInboxListener(onMessagesChanged: { messages, unreadCount, totalCount, canPaginate in
            
            hold = messages.count != count
            
            print("Message Counted updated: \(messages.count)")
            
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
        
        listener.remove()
        
    }
    
}
