//
//  Utils.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/21/25.
//

@testable import Courier_iOS
import Foundation

class Utils {
    
    actor MessageIdStore {
        private var id: String?
        
        func set(_ newValue: String?) {
            id = newValue
        }
        
        func get() -> String? {
            id
        }
    }

    static func sendInboxMessageWithConfirmation(to userId: String) async throws -> (InboxMessage, CourierInboxListener) {
        let messageIdStore = MessageIdStore()
        var listener: CourierInboxListener? = nil

        return try await withCheckedThrowingContinuation { continuation in
            Task {
                
                // Set up our listener first so we don't miss the message
                listener = await Courier.shared.addInboxListener(
                    onMessageEvent: { message, index, feed, event in
                        // The closure might be called on a different concurrency context
                        // so we hop into a Task to safely interact with the actor
                        Task {
                            guard let currentId = await messageIdStore.get() else { return }
                            if event == .added, message.messageId == currentId {
                                // Once we match, clear out the ID and resume
                                await messageIdStore.set(nil)
                                continuation.resume(returning: (message, listener!))
                            }
                        }
                    }
                )

                // Now send a test message that eventually triggers the listener
                let newMessageId = try await ExampleServer.sendTest(
                    authKey: Env.COURIER_AUTH_KEY,
                    userId: userId,
                    channel: "inbox"
                )
                
                // Publish the ID to the actor so the listener can see it
                await messageIdStore.set(newMessageId)
                print("New message sent: \(newMessageId)")

                // Failsafe timeout: if we haven't gotten a matching message in 30s, throw
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                
                if await messageIdStore.get() != nil {
                    continuation.resume(throwing: CourierError.inboxNotInitialized)
                }
            }
        }
    }
    
    static func sendMessageWithDelay(to userId: String, channel: String = "inbox", delay: UInt64 = 30_000_000_000) async throws -> String {
        let messageId = try await ExampleServer.sendTest(
            authKey: Env.COURIER_AUTH_KEY,
            userId: userId,
            channel: channel
        )
        print("New message sent: \(messageId)")
        try? await Task.sleep(nanoseconds: delay)
        return messageId
    }

}
