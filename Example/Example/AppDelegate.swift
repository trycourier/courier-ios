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
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    private var firebaseMessaging: Messaging {
        get {
            return Messaging.messaging()
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Courier.configure(self)
        
        // Initialize Firebase and FCM
        FirebaseApp.configure()
        firebaseMessaging.delegate = self
        
        return true
        
    }
    
//    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        
//        // Initialize Firebase and FCM
//        FirebaseApp.configure()
//        firebaseMessaging.delegate = self
//        
//        return true
//        
//    }
    
//    // MARK: Firebase Cloud Messaging Support
//    
//    override func deviceTokenDidChange(rawApnsToken: Data, isDebugging: Bool) {
//        
//        firebaseMessaging.setAPNSToken(rawApnsToken, type: isDebugging ? .sandbox : .prod)
//        
//    }
//    
//    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//
//        guard let token = fcmToken else { return }
//
//        Task {
//            do {
//                try await Courier.shared.setToken(provider: .firebaseFcm, token: token)
//            } catch {
//                print(String(describing: error))
//            }
//        }
//
//    }
//
//    // MARK: Push Notification Handlers
//
//    override func pushNotificationDeliveredInForeground(message: [AnyHashable : Any]) -> UNNotificationPresentationOptions {
//        
//        let json = message.toJson() ?? "Error"
//        
//        print("\n=== 💌 Push Notification Delivered In Foreground ===\n")
//        print(json)
//        print("\n=================================================\n")
//        
//        // This is how you want to show your notification in the foreground
//        // You can pass "[]" to not show the notification to the user or
//        // handle this with your own custom styles
//        return [.sound, .list, .banner, .badge]
//        
//    }
//    
//    override func pushNotificationClicked(message: [AnyHashable : Any]) {
//        
//        let json = message.toJson() ?? "Error"
//        
//        print("\n=== 👉 Push Notification Clicked ===\n")
//        print(json)
//        print("\n=================================\n")
//        
//        showMessageAlert(title: "Message Clicked", message: json)
//        
//    }


}

