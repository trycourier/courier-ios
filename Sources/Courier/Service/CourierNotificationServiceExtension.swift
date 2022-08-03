//
//  CourierNotificationServiceExtension.swift
//  
//
//  Created by Michael Miller on 8/3/22.
//

import UserNotifications
import UIKit

open class CourierNotificationServiceExtension: UNNotificationServiceExtension {

    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?

    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let notification = bestAttemptContent {
            testAPI { statusCode in
                notification.title = "\(notification.title) [Courier SDK 🐣]"
                notification.subtitle = "\(notification.subtitle) [\(statusCode)]"
                notification.body = notification.body + " or whatever"
                contentHandler(notification)
            }
        }
        
    }
    
    open override func serviceExtensionTimeWillExpire() {
        
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
        
    }
    
    private func testAPI(completionHandler: @escaping (String) -> Void) {
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!

        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 420
            completionHandler("\(statusCode)")
        })
        
        task.resume()
        
    }
    
}
