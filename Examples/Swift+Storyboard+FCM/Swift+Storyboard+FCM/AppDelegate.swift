//
//  AppDelegate.swift
//  Swift+Storyboard+FCM
//
//  Created by Michael Miller on 7/21/22.
//

import UIKit
import Courier
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: CourierDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize your firebase project
        // 1. Follow these steps: https://firebase.google.com/docs/ios/setup
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        // Be sure you have created a new APNS key and have uploaded it here before you get started
        // 2. Create new APNS key here: https://developer.apple.com/account/resources/authkeys/add
        // 3. Upload your APNS key to your Firebase Account: https://console.firebase.google.com/project/YOUR_PROJECT_ID/settings/cloudmessaging
        // 4. Get the Firebase Service Key JSON from here (Click "Generate New Private Key"): https://console.firebase.google.com/project/YOUR_PROJECT_ID/settings/serviceaccounts/adminsdk
        // 5. Upload the Firebase Service Key JSON to here: https://app.courier.com/channels/firebase-fcm
        
        return true
    }
    
    // MARK: Courier Notification Functions
    
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
      Task.init {
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
