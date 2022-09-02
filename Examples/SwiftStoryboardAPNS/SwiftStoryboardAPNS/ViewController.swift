//
//  ViewController.swift
//  SwiftStoryboardAPNS
//
//  Created by Michael Miller on 8/26/22.
//

import UIKit
import Courier

enum UserDefaultKey: String, CaseIterable {
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
                providers: [.apns]
            )
            
        }
        
    }
    
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBAction func authButtonAction(_ sender: Any) {
        
        Task {
            
            if let _ = Courier.shared.userId {
                
                try await Courier.shared.signOut()
                refreshUser()
                
            } else {
                
                try await UIApplication.shared.currentWindow?.rootViewController?.showInputAlert(
                    fields: UserDefaultKey.allCases
                )
                
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
                
                refreshUser()

                // You should requests this permission in a place that
                // makes most sense for your user's experience
                try await Courier.requestNotificationPermissions()
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshUser()
        
//        Task {
//
//            refreshUser()
//
//            try await UIApplication.shared.currentWindow?.rootViewController?.showInputAlert(
//                fields: UserDefaultKey.allCases
//            )
//
//            // To hide debugging logs
//            // Courier.shared.isDebugging = false
//
//            // Set the access token to your user id
//            // You can use a Courier auth key for this
//            // but it is recommended that use use a jwt linked to your user
//            // More info: https://www.courier.com/docs/reference/auth/issue-token/
//
//            // This should be synced with your user's state management to ensure
//            // your users tokens don't receive notifications when they are not
//            // authenticated to use your app
//            try await Courier.shared.setCredentials(
//                accessToken: getDefault(key: .accessToken),
//                userId: getDefault(key: .userId)
//            )
//
//            refreshUser()
//
//            // You should requests this permission in a place that
//            // makes most sense for your user's experience
//            try await Courier.requestNotificationPermissions()
//
//            // To remove the tokens for the current user, call this function.
//            // You should call this when your user signs out of your app
//            // try await Courier.shared.signOut()
//
//        }
        
    }
    
    private func refreshUser() {
        
        if let userId = Courier.shared.userId {
            authLabel.text = "Courier User Id: \(userId)"
            authButton.setTitle("Sign Out", for: .normal)
        } else {
            authLabel.text = "No Courier User Id found"
            authButton.setTitle("Sign In", for: .normal)
        }
        
    }


}

