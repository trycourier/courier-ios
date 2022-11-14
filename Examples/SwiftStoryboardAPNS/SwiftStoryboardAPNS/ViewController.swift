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
                authKey: Env.COURIER_AUTH_KEY,
                userId: Env.COURIER_USER_ID,
                title: "APNS Test Push",
                message: "Hello from Courier \(Env.COURIER_USER_ID)! 👋",
                providers: [CourierProvider.apns.rawValue],
                isProduction: false // TODO: *You are responsible for handling this value* false is sandbox, true is production
            )
            
        }
        
    }
    
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBAction func authButtonAction(_ sender: Any) {
        
        Task {
            
            if let _ = Courier.shared.userId {
                
                try await Courier.shared.signOut()
                refresh()
                
            } else {
                
//                try await UIApplication.shared.currentWindow?.rootViewController?.showInputAlert(
//                    fields: UserDefaultKey.allCases
//                )
                
                // To hide debugging logs
                // Courier.shared.isDebugging = false
                
                // Set the access token to your user id
                // You can use a Courier auth key for this
                // but it is recommended that use use a jwt linked to your user
                // More info: https://www.courier.com/docs/reference/auth/issue-token/
                
                // This should be synced with your user's state management to ensure
                // your users tokens don't receive notifications when they are not
                // authenticated to use your app
                try await Courier.shared.signIn(
                    accessToken: Env.COURIER_ACCESS_TOKEN,
                    userId: Env.COURIER_USER_ID
                )
                
                refresh()

                // You should requests this permission in a place that
                // makes most sense for your user's experience
                try await Courier.requestNotificationPermission()
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        
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


}

