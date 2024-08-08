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
        
        Task {
            do {
                if let trackingUrl = notification.userInfo["trackingUrl"] as? String {
                    try await CourierClient.default.tracking.postTrackingUrl(
                        url: trackingUrl,
                        event: .delivered
                    )
                }
            } catch {
                Courier.shared.client?.options.error(error.localizedDescription)
            }
        }
        
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
