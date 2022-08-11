//
//  AppDelegate.swift
//  Demo
//
//  Created by Michael Miller on 8/9/22.
//

import UIKit
import Courier
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: CourierDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Register callback to receive fcm token changes
        Messaging.messaging().delegate = self
        
        return true
        
    }
    
    // MARK: Courier Notification Support

    override func pushNotificationReceivedInForeground(message: [AnyHashable : Any]) -> UNNotificationPresentationOptions {

        print("Push Received")
        print(message)

        // ⚠️ For demo purposes only
        showMessageAlert(title: "Push Received", message: "\(message)")

        return [.list, .badge, .banner, .sound]

    }

    override func pushNotificationOpened(message: [AnyHashable : Any]) {

        print("Push Opened")
        print(message)

        // ⚠️ For demo purposes only
        showMessageAlert(title: "Push Opened", message: "\(message)")

    }

}

extension AppDelegate: MessagingDelegate {
  
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Task {
            do {
                if let token = fcmToken {
                    try await Courier.shared.setPushToken(
                        provider: .fcm,
                        token: token
                    )
                }
            } catch {
                print(error)
            }
        }
    }

}
