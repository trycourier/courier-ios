//
//  InboxTests.swift
//
//
//  Created by Michael Miller on 7/23/24.
//

import XCTest
@testable import Courier_iOS

class InboxTests: XCTestCase {
    
    private let delay: UInt64 = 5_000_000_000
    
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
        
        let listener = Courier.shared.addInboxListener(onMessagesChanged: { messages, unreadCount, totalCount, canPaginate in
            print("Messages Updated: \(messages.count)")
            hold = messages.count < count
        })
        
        // Send some messages
        for _ in 1...count {
            try await sendMessage()
        }
        
        try? await Task.sleep(nanoseconds: delay)
        
        while (hold) {
            // Hold
        }

        listener.remove()
        
        Courier.shared.inboxPaginationLimit = 32
        XCTAssertTrue(Courier.shared.inboxPaginationLimit == 32)

    }
    
}
