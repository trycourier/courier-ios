//
//  AppDelegate.swift
//  Example-storyboard-apns-fcm
//
//  Created by Fahad Amin on 11/11/22.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import Courier

func signInWithCourier() {
    
    Task.init {

        let userId = Env.COURIER_USER_ID
        
        // Courier needs you to generate an access token on your backend
        // Docs for setting this up: https://www.courier.com/docs/reference/auth/issue-token/
        let accessToken = Env.COURIER_ACCESS_TOKEN

        // Set Courier user credentials
        try await Courier.shared.signIn(accessToken: accessToken, userId: userId)
    }
    
}

@main
class AppDelegate: CourierDelegate {
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        fcmConfiguration()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
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
    
    private func fcmConfiguration(){
        FirebaseApp.configure()
        Messaging.messaging().delegate = appDelegate
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
