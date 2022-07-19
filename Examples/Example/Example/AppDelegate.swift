//
//  AppDelegate.swift
//  Example
//
//  Created by Michael Miller on 7/7/22.
//

import UIKit
import Courier

@main
class AppDelegate: CourierDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Courier.shared.authorizationKey = "pk_prod_3EH7GNYRC9409PMQGRQE37GC6ABP"
        Courier.shared.user = CourierUser(id: "ryan")
        
        Courier.requestNotificationPermissions { status in
            print(status.rawValue)
        }
        
        return true
    }

    override func pushNotificationReceivedInForeground(message: [AnyHashable : Any], showForegroundNotificationAs: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Push Received")
        print(message)
        showForegroundNotificationAs([.badge, .list, .sound, .banner])
    }

    override func pushNotificationOpened(message: [AnyHashable : Any], appState: UIApplication.State) {
        print("Push Opened")
        print(message)
    }

}

