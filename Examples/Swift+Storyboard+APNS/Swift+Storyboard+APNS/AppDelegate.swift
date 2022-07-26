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
    
    // MARK: Courier Notification Functions
    
    override func pushNotificationReceivedInForeground(message: [AnyHashable : Any], presentAs showForegroundNotificationAs: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Push Received")
        print(message)
        
        // ⚠️ Customize this to be what you would like
        // Pass an empty array to this if you do not want to use it
        showForegroundNotificationAs([.list, .badge, .banner, .sound])
        
        // ⚠️ For demo purposes only
        showMessageAlert(title: "Push Received", message: "\(message)")
        
    }
    
    override func pushNotificationOpened(message: [AnyHashable : Any]) {
        
        print("Push Opened")
        print(message)
        
        // ⚠️ For demo purposes only
        showMessageAlert(title: "Push Opened", message: "\(message)")
        
    }

}

//    If you do not want to use CourierDelegate to get started. Here is what you can extend.
//    You still need to be sure that you call Courier.shared.setUserProfile(...)

//    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Task.init {
//            do {
//                let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//                try await Courier.shared.setPushToken(
//                    provider: .apns,
//                    token: token
//                )
//            } catch {
//                debugPrint(error)
//            }
//        }
//    }

