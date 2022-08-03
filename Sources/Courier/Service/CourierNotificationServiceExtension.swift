//
//  CourierNotificationServiceExtension.swift
//  
//
//  Created by Michael Miller on 8/3/22.
//

import UserNotifications
import UIKit

class CourierNotificationServiceExtension: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            
            if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
                bestAttemptContent.title = "\(bestAttemptContent.title) [\(deviceId)]"
            } else {
                bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}
