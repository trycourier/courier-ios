//
//  CourierNotificationServiceExtension.swift
//  
//
//  Created by Michael Miller on 8/3/22.
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
        Courier.trackNotification(
            message: notification.userInfo,
            event: .read
        )
        
        // TODO: Remove me
        notification.title = "\(notification.title) [Posted]"
        
        // Show the notification
        contentHandler(notification)
        
    }
    
    open override func serviceExtensionTimeWillExpire() {
        
        // If all fails, return present the original notification
        if let handler = originalHandler, let content = originalContent {
            handler(content)
        }
        
    }
    
}
