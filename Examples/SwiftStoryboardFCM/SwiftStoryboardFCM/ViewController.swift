//
//  ViewController.swift
//  SwiftStoryboardFCM
//
//  Created by Michael Miller on 8/26/22.
//

import UIKit
import Courier
import FirebaseCore
import FirebaseMessaging

enum UserDefaultKey: String, CaseIterable {
    case googleAppId = "Google App ID"
    case gcmSendId = "GCM Sender ID"
    case projectID = "Firebase Project ID"
    case apiKey = "Firebase API Key"
    case accessToken = "Courier Access Token JWT"
    case authKey = "Courier Auth Key"
    case userId = "Courier User ID"
}

class ViewController: UIViewController {

    @IBAction func sendPush(_ sender: Any) {
        
        Task {
            
            try await Courier.shared.sendPush(
                authKey: getDefault(key: .authKey),
                userId: getDefault(key: .userId),
                title: "Test Push Notification",
                message: "Hello from Courier! 🐣",
                providers: [.fcm]
            )
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            
            try await UIApplication.shared.currentWindow?.rootViewController?.showInputAlert(
                fields: UserDefaultKey.allCases
            )
            
            // Configure firebase before other parts of the app start
            // There may be issues if you do not configure firebase at this point
            firebaseConfig()
            
            // To hide debugging logs
            // Courier.shared.isDebugging = false
            
            // Set the access token to your user id
            // You can use a Courier auth key for this
            // but it is recommended that use use a jwt linked to your user
            // More info: https://www.courier.com/docs/reference/auth/issue-token/
            
            // This should be synced with your user's state management to ensure
            // your users tokens don't receive notifications when they are not
            // authenticated to use your app
            try await Courier.shared.setCredentials(
                accessToken: getDefault(key: .accessToken),
                userId: getDefault(key: .userId)
            )
            
            // You should requests this permission in a place that
            // makes most sense for your user's experience
            try await Courier.requestNotificationPermissions()
            
            // Manually link the APNS token to Firebase again
            // Just to be sure the FCM token is ready
            if let token = Courier.shared.rawApnsToken {
                appDelegate.deviceTokenDidChange(
                    rawApnsToken: token,
                    isDebugging: Courier.shared.isDebugging
                )
            }
            
            // To remove the tokens for the current user, call this function.
            // You should call this when your user signs out of your app
            // try await Courier.shared.signOut()
            
        }
        
    }
    
    private func firebaseConfig() {
        
        // Configure firebase programatically
        // You can also do this with the GoogleService-Info.plist file
        let options = FirebaseOptions(
            googleAppID: getDefault(key: .googleAppId),
            gcmSenderID: getDefault(key: .gcmSendId)
        )
        options.projectID = getDefault(key: .projectID)
        options.apiKey = getDefault(key: .apiKey)
        
        FirebaseApp.configure(options: options)
        
        // Register the messaging delegate
        Messaging.messaging().delegate = appDelegate
        
    }

}

