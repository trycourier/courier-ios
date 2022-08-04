//
//  AppDelegate.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 7/21/22.
//

import UIKit
import Courier

@main
class AppDelegate: CourierDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Be sure you have created a new APNS key and have uploaded it here before you get started
        // 1. Create new APNS key here: https://developer.apple.com/account/resources/authkeys/add
        // 2. Upload your APNS key here: https://app.courier.com/channels/apn
        
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
