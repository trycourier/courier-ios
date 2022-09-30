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
    
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBAction func authButtonAction(_ sender: Any) {
        
        Task {
            
            if let _ = Courier.shared.userId {
                try await Courier.shared.signOut()
            } else {
                try await Courier.shared.setCredentials(
                    accessToken: getDefault(key: .accessToken),
                    userId: getDefault(key: .userId)
                )
            }
            
            refresh()
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            
            try await UIApplication.shared.currentWindow?.rootViewController?.showInputAlert(
                fields: UserDefaultKey.allCases
            )
            
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
            
            refresh()
            
        }
        
    }
    
    private func refresh() {
        
        if let userId = Courier.shared.userId {
            authLabel.text = "Courier User Id: \(userId)"
            authButton.setTitle("Sign Out", for: .normal)
        } else {
            authLabel.text = "No Courier User Id found"
            authButton.setTitle("Sign In", for: .normal)
        }
        
    }
    
    private func firebaseConfig() {
        
        Task {
            
            await FirebaseApp.app()?.delete()
            
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

}
