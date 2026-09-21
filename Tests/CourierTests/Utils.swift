//
//  Utils.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/21/25.
//

@testable import Courier_iOS
import Foundation

/// Failures raised by the test helpers themselves.
///
/// Deliberately not a `CourierError`: these helpers used to report a timeout as
/// `CourierError.inboxNotInitialized`, which surfaces as `403 "Courier Inbox is not initialized"`
/// and reads exactly like a response from the API. It is not one -- it means the message never
/// arrived. Keep helper failures in their own type so they can never be mistaken for one.
enum TestFailure: LocalizedError {

    case timedOutWaitingForMessage(messageId: String, userId: String, tenantId: String?, seconds: Int)
    case timedOut(description: String, seconds: Int)

    var errorDescription: String? {
        switch self {
        case let .timedOut(description, seconds):
            return "Timed out after \(seconds)s waiting for \(description)."
        case let .timedOutWaitingForMessage(messageId, userId, tenantId, seconds):
            let tenant = tenantId.map { ", tenant \($0)" } ?? ""
            return """
                Timed out after \(seconds)s waiting for inbox message \(messageId) \
                (user \(userId)\(tenant)). The send itself succeeded, so the message was accepted \
                but never reached the inbox listener. This is usually a workspace fixture problem \
                -- see .agents/skills/run-tests/SKILL.md.
                """
        }
    }

}

class Utils {

    /// Runs `operation`, throwing `TestFailure.timedOut` if it has not finished in time.
    ///
    /// Use this around any wait that resumes only on success. A bare continuation that resumes
    /// from a callback hangs forever when the callback never fires, and xcodebuild reports that as
    /// a hung test killed by the execution-time allowance rather than as a failure -- which costs
    /// a full CI timeout and says nothing about what went wrong.
    static func withTimeout<T: Sendable>(
        seconds: Int,
        description: String,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in

            group.addTask { try await operation() }
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
                throw TestFailure.timedOut(description: description, seconds: seconds)
            }

            guard let result = try await group.next() else {
                throw TestFailure.timedOut(description: description, seconds: seconds)
            }

            group.cancelAll()
            return result

        }
    }

    actor MessageIdStore {
        private var id: String?
        private var listener: CourierInboxListener?
        
        func set(_ newValue: String?) {
            id = newValue
        }
        
        func get() -> String? {
            id
        }

        func setListener(_ newValue: CourierInboxListener) {
            listener = newValue
        }

        func getListener() -> CourierInboxListener? {
            listener
        }
    }

    static func sendInboxMessageWithConfirmation(to userId: String, tenantId: String? = nil) async throws -> (InboxMessage, CourierInboxListener) {
        let messageIdStore = MessageIdStore()

        return try await withCheckedThrowingContinuation { continuation in
            Task {
                
                // Set up our listener first so we don't miss the message
                let listener = await Courier.shared.addInboxListener(
                    onMessageEvent: { message, index, feed, event in
                        // The closure might be called on a different concurrency context
                        // so we hop into a Task to safely interact with the actor
                        Task {
                            guard let currentId = await messageIdStore.get() else { return }
                            if event == .added, message.messageId == currentId, let listener = await messageIdStore.getListener() {
                                // Once we match, clear out the ID and resume
                                await messageIdStore.set(nil)
                                continuation.resume(returning: (message, listener))
                            }
                        }
                    }
                )

                // Make the listener available to the callback above
                await messageIdStore.setListener(listener)

                // Now send a test message that eventually triggers the listener
                let newMessageId = try await ExampleServer.sendTest(
                    authKey: Env.COURIER_AUTH_KEY,
                    userId: userId,
                    tenantId: tenantId,
                    channel: "inbox"
                )
                
                var savableMessageId = newMessageId
                
                // This is such a hack...
                // The backend needs love 💔
                if tenantId != nil {
                    savableMessageId += ":\(userId)"
                }
                
                // Publish the ID to the actor so the listener can see it
                await messageIdStore.set(savableMessageId)
                print("New message sent: \(savableMessageId)")

                // Failsafe timeout: if we haven't gotten a matching message in 30s, throw
                let timeoutSeconds = 30
                try? await Task.sleep(nanoseconds: UInt64(timeoutSeconds) * 1_000_000_000)

                if await messageIdStore.get() != nil {
                    continuation.resume(
                        throwing: TestFailure.timedOutWaitingForMessage(
                            messageId: savableMessageId,
                            userId: userId,
                            tenantId: tenantId,
                            seconds: timeoutSeconds
                        )
                    )
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
