//
//  Utils.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/21/25.
//

@testable import Courier_iOS
import Foundation

class Utils {
    
    static func sendMessageAndWaitForDelivery(to userId: String) async throws -> (InboxMessage, CourierInboxListener) {
        return try await withCheckedThrowingContinuation { continuation in
            
            let lock = NSLock()
            var didFinish = false
            
            func finish(_ result: Result<(InboxMessage, CourierInboxListener), Error>) {
                lock.lock()
                defer { lock.unlock() }
                guard !didFinish else { return }
                didFinish = true
                
                switch result {
                case .success(let (message, listener)):
                    continuation.resume(returning: (message, listener))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            Task {
                do {
                    
                    // Ensure messageId is assigned before adding the listener
                    let messageId = try await InboxTests.sendMessage()
                    var listener: CourierInboxListener? = nil
                    
                    // Initialize listener
                    listener = await Courier.shared.addInboxListener(onMessageEvent: { message, index, feed, event in
                        if event == .added && message.messageId == messageId {
                            finish(.success((message, listener!)))
                        }
                    })
                    
                    // Sleep for 30 seconds to create a timeout.
                    try? await Task.sleep(nanoseconds: 30_000_000_000)
                    
                    // Timeout reached, fail safely.
                    finish(.failure(CourierError.inboxNotInitialized))
                    
                    // Ensure listener is removed on failure
                    await Courier.shared.removeInboxListener(listener!)
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
