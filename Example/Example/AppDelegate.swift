//
//  AppDelegate.swift
//  Example
//
//  Created by https://github.com/mikemilla on 11/17/22.
//

import UIKit
import Courier_iOS
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: CourierDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize Firebase and FCM
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        return true
        
    }

    // MARK: Push Notification Handlers

    override func pushNotificationDeliveredInForeground(message: [AnyHashable : Any]) -> UNNotificationPresentationOptions {
        
        print("\n=== 💌 Push Notification Delivered In Foreground ===\n")
        print(message)
        print("\n=================================================\n")
        
        // This is how you want to show your notification in the foreground
        // You can pass "[]" to not show the notification to the user or
        // handle this with your own custom styles
        return [.sound, .list, .banner, .badge]
        
    }
    
    override func pushNotificationClicked(message: [AnyHashable : Any]) {
        
        print("\n=== 👉 Push Notification Clicked ===\n")
        print(message)
        print("\n=================================\n")
        
        showMessageAlert(title: "Message Clicked", message: "\(message)")
        
    }
    
    // MARK: Firebase Cloud Messaging Support
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

        guard let token = fcmToken else { return }

        Task {
            do {
                try await Courier.shared.setFCMToken(token)
            } catch {
                print(String(describing: error))
            }
        }

    }


}

