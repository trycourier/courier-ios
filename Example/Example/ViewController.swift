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
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var apnsSwitch: UISwitch!
    @IBOutlet weak var fcmSwitch: UISwitch!
    
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
    
    func getTitle() -> String {
        if(apnsSwitch.isOn && fcmSwitch.isOn){
            return "APNS & FCM Test Push"
        }else if(apnsSwitch.isOn){
            return "APNS Test Push"
        }else if(fcmSwitch.isOn){
            return "FCM Test Push"
        }
        return ""
    }
    
    @IBAction func sendPushAction(_ sender: Any) {
        
        // TODO: Be sure to handle errors
        
        Task {
            
            var providers: [CourierProvider] = []
            
            if(apnsSwitch.isOn){
                providers.append(.apns)
            }
            
            if(fcmSwitch.isOn){
                providers.append(.fcm)
            }
            
            let title = getTitle()
            
            if(!providers.isEmpty){
                try await Courier.shared.sendPush(
                    authKey: Env.COURIER_AUTH_KEY,
                    userId: Env.COURIER_USER_ID,
                    title: title,
                    message: "Hello from Courier \(Env.COURIER_USER_ID)! 👋",
                    isProduction: false,
                    providers: providers
                )
            }
            
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
//            segmentedControl.isEnabled = true
            
        } else {
            
            authButton.setTitle("Sign In", for: .normal)
            authLabel.text = "No Courier User Id Found"
            sendButton.isEnabled = false
        }
        
    }
    
}

