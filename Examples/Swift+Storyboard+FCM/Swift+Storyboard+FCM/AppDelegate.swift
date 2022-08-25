//
//  AppDelegate.swift
//  Swift+Storyboard+FCM
//
//  Created by Michael Miller on 8/12/22.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import Courier

@main
class AppDelegate: CourierDelegate {
    
    // If you extend the CourierDelegate, the Courier SDK will
    // automatically manage the APNS token and track notification status analytics
    
    override func pushNotificationDeliveredInForeground(message: [AnyHashable : Any]) -> UNNotificationPresentationOptions {
        
        print("\n=== 💌 Push Notification Delivered In Foreground ===\n")
        print(message)
        print("\n=================================================\n")
        
        showMessageAlert(title: "Push Delivered", message: "\(message)")
        
        // This is how you want to show your notification in the foreground
        // You can pass "[]" to not show the notification to the user or
        // handle this with your own custom styles
        return [.sound, .list, .banner, .badge]
        
    }
    
    override func pushNotificationClicked(message: [AnyHashable : Any]) {
        
        print("\n=== 👉 Push Notification Clicked ===\n")
        print(message)
        print("\n=================================\n")
        
        showMessageAlert(title: "Push Clicked", message: "\(message)")
        
    }
    
    override func deviceTokenDidChange(rawApnsToken: Data, isDebugging: Bool) {
        
        // Sync the current apns token with firebase
        // This will trigger other important FCM functions to get called
        // Be sure to handle the type properly here in your production app
        Messaging.messaging().setAPNSToken(rawApnsToken, type: isDebugging ? .sandbox : .prod)
        
    }

}

extension AppDelegate: MessagingDelegate {
  
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Task {
            do {
                if let token = fcmToken {
                    try await Courier.shared.setFCMToken(token)
                }
            } catch {
                print(error)
            }
        }
    }

}

