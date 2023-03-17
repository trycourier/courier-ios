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
        
        originalHandler = contentHandler
        originalContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let notification = originalContent else {
            return
        }
        
        // Try and track the notification
        // Async, does not wait for completion
        Courier.shared.trackNotification(message: notification.userInfo, event: .delivered)
        
        // Show the notification
        contentHandler(notification)
        
    }
    
    open override func serviceExtensionTimeWillExpire() {
        
        // If all fails, present the original notification
        if let handler = originalHandler, let content = originalContent {
            handler(content)
        }
        
    }
    
}
