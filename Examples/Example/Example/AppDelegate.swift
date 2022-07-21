//
//  AppDelegate.swift
//  Example
//
//  Created by Michael Miller on 7/7/22.
//

import UIKit
import Courier
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: CourierDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // FCM Pieces
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        // Courier Pieces
        Courier.shared.authorizationKey = "pk_prod_3EH7GNYRC9409PMQGRQE37GC6ABP"
        Courier.shared.user = CourierUser(id: "fcm_user_1")
        
        Courier.requestNotificationPermissions { status in
            print(status.rawValue)
        }
        
        return true
    }

    override func pushNotificationReceivedInForeground(message: [AnyHashable : Any], presentAs showForegroundNotificationAs: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Push Received")
        print(message)
        showForegroundNotificationAs([.badge, .list, .sound, .banner])
    }

    override func pushNotificationOpened(message: [AnyHashable : Any]) {
        print("Push Opened")
        print(message)
    }

}

extension AppDelegate: MessagingDelegate {
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      if let token = fcmToken {
          print("Firebase registration token: \(token)")
          Courier.shared.updateFCMToken(token)
      }
  }

}
