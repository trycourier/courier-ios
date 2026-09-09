//
//  CourierNotificationServiceExtension.swift
//  
//
//  Created by https://github.com/mikemilla on 8/3/22.
//

import UserNotifications
import UIKit

// The system drives this object from one thread at a time, and the two stored properties are
// written before any asynchronous work starts.
open class CourierNotificationServiceExtension: UNNotificationServiceExtension, @unchecked Sendable {

    private var originalHandler: ((UNNotificationContent) -> Void)?
    private var originalContent: UNMutableNotificationContent?

    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        // Copy the original message first so it can still be delivered if the service's time expires
        originalHandler = contentHandler
        originalContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        Task {
            
            guard let notification = originalContent else {
                return
            }
            
            // Track the message in Courier
            await notification.userInfo.trackMessage(event: .delivered)
            
            // Show the notification
            originalHandler?(notification)
            
        }
        
    }
    
    open override func serviceExtensionTimeWillExpire() {
        
        // If all fails, present the original notification
        if let handler = originalHandler, let content = originalContent {
            handler(content)
        }
        
    }
    
}
