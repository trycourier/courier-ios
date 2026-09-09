//
//  CourierNotificationServiceExtension.swift
//  
//
//  Created by https://github.com/mikemilla on 8/3/22.
//

import UserNotifications
import UIKit

/// A notification waiting on Courier tracking, together with the handler that shows it.
private struct PendingDelivery {
    let handler: (UNNotificationContent) -> Void
    let content: UNMutableNotificationContent
}

// The only state is the pending delivery, which lives behind a lock so the tracking task and
// serviceExtensionTimeWillExpire can race for it safely.
open class CourierNotificationServiceExtension: UNNotificationServiceExtension, @unchecked Sendable {

    private let pendingDelivery = LockedValue<PendingDelivery?>(nil)

    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        guard let content = request.content.mutableCopy() as? UNMutableNotificationContent else {
            contentHandler(request.content)
            return
        }
        
        // Hold the original message so it can still be delivered if the service's time expires
        pendingDelivery.value = PendingDelivery(handler: contentHandler, content: content)
        
        Task {
            
            // Track the message in Courier
            let userInfo = pendingDelivery.value?.content.userInfo ?? [:]
            await userInfo.trackMessage(event: .delivered)
            
            // Show the notification
            deliverPendingContent()
            
        }
        
    }
    
    open override func serviceExtensionTimeWillExpire() {
        
        // If all fails, present the original notification
        deliverPendingContent()
        
    }
    
    /// Delivers the pending notification exactly once. The system forbids calling the content handler twice.
    private func deliverPendingContent() {
        guard let delivery = pendingDelivery.swap(nil) else {
            return
        }
        delivery.handler(delivery.content)
    }
    
}
