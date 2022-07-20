//
//  AppDelegate.swift
//  Swift_XIB_Example
//
//  Created by Michael Miller on 7/20/22.
//

import UIKit
import Courier

@main
class AppDelegate: CourierDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize the Courier SDK by setting your authorization key
        // Your authorization key can be found here: https://app.courier.com/settings/api-keys
        Courier.shared.authorizationKey = "pk_prod_3EH7GNYRC9409PMQGRQE37GC6ABP"
        
        return true
    }
    
    // MARK: Courier Notification Functions
    
    override func pushNotificationReceivedInForeground(message: [AnyHashable : Any], showForegroundNotificationAs: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Push Received")
        print(message)
        showForegroundNotificationAs([.list, .badge, .banner, .sound])
        
    }
    
    override func pushNotificationOpened(message: [AnyHashable : Any], appState: UIApplication.State) {
        
        print("Push Received")
        print(message)
        
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


}

