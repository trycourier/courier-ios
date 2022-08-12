//
//  AppDelegate.swift
//  Swift+Storyboard+FCM
//
//  Created by Michael Miller on 8/12/22.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import Courier

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Init Firebase
        
        
        FirebaseApp.configure(options: options)
        
//        if let token = Courier.shared.rawApnsToken {
//            Messaging.messaging().setAPNSToken(token, type: .sandbox)
//        }
        
        return true
    }

}

