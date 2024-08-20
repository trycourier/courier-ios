//
//  NotificationService.swift
//  CourierService
//
//  Created by Fahad Amin on 11/18/22.
//

import Courier_iOS
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    private var originalHandler: ((UNNotificationContent) -> Void)?
    private var originalContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        Task {
            
            // Copy the original message
            originalHandler = contentHandler
            originalContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
            
            guard let notification = originalContent else {
                return
            }
            
            // Track the message in Courier
            if let trackingUrl = notification.userInfo["trackingUrl"] as? String {
                let client = CourierClient.default
                do {
                    try await client.tracking.postTrackingUrl(
                        url: trackingUrl,
                        event: .delivered
                    )
                } catch {
                    client.options.error(error.localizedDescription)
                }
            }
            
            // Get the category for the notification
            if let category = notification.getCategoryWithActions() {
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.setNotificationCategories([category])
                notification.categoryIdentifier = category.identifier
            }
            
            contentHandler(notification)
            
        }
        
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let handler = originalHandler, let content = originalContent {
            handler(content)
        }
    }

}

extension UNNotificationContent {
    
    func getCategoryWithActions() -> UNNotificationCategory? {
        
        guard let actionsArray = self.userInfo["aps"] as? [String: Any],
              let actions = actionsArray["actions"] as? [[String: Any]] else {
            return nil
        }
        
        var notificationActions: [UNNotificationAction] = []
        
        for actionDict in actions {
            if let identifier = actionDict["identifier"] as? String,
               let title = actionDict["title"] as? String,
               let optionsArray = actionDict["options"] as? [String] {
                
                var options: UNNotificationActionOptions = []
                
                // Map options to UNNotificationActionOptions
                if optionsArray.contains("foreground") {
                    options.insert(.foreground)
                }
                if optionsArray.contains("destructive") {
                    options.insert(.destructive)
                }
                if optionsArray.contains("authenticationRequired") {
                    options.insert(.authenticationRequired)
                }
                
                let action = UNNotificationAction(identifier: identifier, title: title, options: options)
                notificationActions.append(action)
            }
        }
        
        return UNNotificationCategory(
            identifier: "CUSTOM_CATEGORY",
            actions: notificationActions,
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        
    }
    
}
