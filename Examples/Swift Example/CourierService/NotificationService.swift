//
//  NotificationService.swift
//  CourierService
//
//  Created by Michael Miller on 8/9/22.
//

import Courier
import UserNotifications

class NotificationService: CourierNotificationServiceExtension {

    //
    //         ^      ╔══════════════════════════════╗
    //       >' )     ║ You can override this class, ║
    //       ( ( \   <  but it is not recommended    ║
    //      mm''|\    ╚══════════════════════════════╝
    //
    
    private var originalHandler: ((UNNotificationContent) -> Void)?
    private var originalContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        originalHandler = contentHandler
        originalContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let notification = originalContent else {
            return
        }
        
//        // Try and track the notification
//        // Async, does not wait for completion
//        Courier.trackNotification(message: notification.userInfo, event: .delivered)
        
        notification.title = "Gotchya!"
        
        // Show the notification
        contentHandler(notification)
        
    }

}
