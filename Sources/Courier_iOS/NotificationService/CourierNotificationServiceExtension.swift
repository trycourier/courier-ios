//
//  CourierNotificationServiceExtension.swift
//  
//
//  Created by https://github.com/mikemilla on 8/3/22.
//

import UserNotifications
import UIKit

open class CourierNotificationServiceExtension: UNNotificationServiceExtension {

    private var originalHandler: ((UNNotificationContent) -> Void)?
    private var originalContent: UNMutableNotificationContent?

    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        // Copy the original message
        originalHandler = contentHandler
        originalContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let notification = originalContent else {
            return
        }

        // The system guarantees `contentHandler` is called once. Capturing these
        // non-Sendable values into the tracking Task is safe under that contract.
        nonisolated(unsafe) let handler = contentHandler
        nonisolated(unsafe) let content = notification

        Task {

            // Track the message in Courier
            await content.userInfo.trackMessage(event: .delivered)

            // Show the notification
            handler(content)

        }
        
    }
    
    open override func serviceExtensionTimeWillExpire() {
        
        // If all fails, present the original notification
        if let handler = originalHandler, let content = originalContent {
            handler(content)
        }
        
    }
    
}
