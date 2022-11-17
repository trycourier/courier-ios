//
//  ViewController.swift
//  Example
//
//  Created by Michael Miller on 11/17/22.
//

import UIKit
import Courier

class ViewController: UIViewController {
    
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func authButtonAction(_ sender: Any) {
        
        // TODO: Be sure to handle errors
        
        Task {
            
            if let _ = Courier.shared.userId {
                
                try await Courier.shared.signOut()
                refresh()
                
            } else {
                
                try await Courier.shared.signIn(
                    accessToken: Env.COURIER_ACCESS_TOKEN,
                    userId: Env.COURIER_USER_ID
                )
                
                refresh()
                
                try await Courier.requestNotificationPermission()
                
            }
            
        }
        
    }
    
    @IBAction func sendPushAction(_ sender: Any) {
        
        // TODO: Be sure to handle errors
        
        Task {
            
            let isApns = segmentedControl.selectedSegmentIndex == 0
            
            try await Courier.shared.sendPush(
                authKey: Env.COURIER_AUTH_KEY,
                userId: Env.COURIER_USER_ID,
                title: isApns ? "APNS Test Push" : "FCM Test Push",
                message: "Hello from Courier \(Env.COURIER_USER_ID)! 👋",
                isProduction: false,
                providers: isApns ? [.apns] : [.fcm]
            )
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    private func refresh() {
        
        if let userId = Courier.shared.userId {
            
            authButton.setTitle("Sign Out", for: .normal)
            authLabel.text = "Courier User Id: \(userId)"
            sendButton.isEnabled = true
            segmentedControl.isEnabled = true
            
        } else {
            
            authButton.setTitle("Sign In", for: .normal)
            authLabel.text = "No Courier User Id Found"
            sendButton.isEnabled = false
            segmentedControl.isEnabled = false
            
        }
        
    }
    
}

