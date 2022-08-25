//
//  AppDelegate.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/12/22.
//

import UIKit
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
    
    // If you do not want to use the CourierDelegate
    // Here is how you can pass your APNS token to Courier manually
    
//    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//        Task {
//
//            do {
//
//                // Pass token to Courier
//                try await Courier.shared.setAPNSToken(deviceToken)
//
//                // Access APNS token as a string
//                let apnsToken = Courier.shared.apnsToken
//
//            } catch {
//                print(error)
//            }
//
//        }
//
//    }

}

