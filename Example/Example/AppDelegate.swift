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
    
    private var firebaseMessaging: Messaging {
        get {
            return Messaging.messaging()
        }
    }
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Initialize Firebase and FCM
        FirebaseApp.configure()
        firebaseMessaging.delegate = self
        
        return true
        
    }
    
    // MARK: Firebase Cloud Messaging Support
    
    override func deviceTokenDidChange(rawApnsToken: Data, isDebugging: Bool) {
        
        firebaseMessaging.setAPNSToken(rawApnsToken, type: isDebugging ? .sandbox : .prod)
        
        firebaseMessaging.token { token, error in
            if let token = token {
                self.uploadFcmToken(token)
            }
        }
        
    }
    
    private func uploadFcmToken(_ token: String) {
        
        Task {
            do {
                try await Courier.shared.setToken(for: .firebaseFcm, token: token)
            } catch {
                print(String(describing: error))
            }
        }
        
    }
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

        guard let token = fcmToken else { return }

        uploadFcmToken(token)

    }

    // MARK: Push Notification Handlers

    override func pushNotificationDeliveredInForeground(message: [AnyHashable : Any]) -> UNNotificationPresentationOptions {
        
        let json = message.toJson() ?? "Error"
        
        print("\n=== 💌 Push Notification Delivered In Foreground ===\n")
        print(json)
        print("\n=================================================\n")
        
        showCodeAlert(title: "Message Delivered", code: json)
        
        // This is how you want to show your notification in the foreground
        // You can pass "[]" to not show the notification to the user or
        // handle this with your own custom styles
        return [.sound, .list, .banner, .badge]
        
    }
    
    override func pushNotificationClicked(message: [AnyHashable : Any]) {
        
        let json = message.toJson() ?? "Error"
        
        print("\n=== 👉 Push Notification Clicked ===\n")
        print(json)
        print("\n=================================\n")
        
        showCodeAlert(title: "Message Clicked", code: json)
        
    }


}
