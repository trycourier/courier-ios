//
//  NotificationsViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 11/17/22.
//

import UIKit
import Courier

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var apnsSwitch: UISwitch!
    @IBOutlet weak var fcmSwitch: UISwitch!
    @IBOutlet weak var inboxSwitch: UISwitch!
    
    @IBAction func sendPushAction(_ sender: Any) {
        
        Task {
            
            var providers: [CourierProvider] = []
            
            if (apnsSwitch.isOn) {
                providers.append(.apns)
            }
            
            if (fcmSwitch.isOn) {
                providers.append(.fcm)
            }
            
            if (inboxSwitch.isOn) {
                providers.append(.inbox)
            }
            
            if let userId = Courier.shared.userId {
                
                let titles = [
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
                    "Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore ",
                    "Ullamco laboris nisi ut aliquip ex ea commodo consequat nisi ut aliquip ex ea commodo consequat duis aute irure dolor",
                    "sunt in culpa qui officia deserunt mollit anim id est laborum."
                ]
                
                let messages = [
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco",
                    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                    "Lorem ipsum dolor sit amet"
                ]
                
                if (!providers.isEmpty) {
                    try await Courier.shared.sendMessage(
                        authKey: Env.COURIER_AUTH_KEY,
                        userId: userId,
                        title: titles.randomElement()!,
                        message: messages.randomElement()!,
                        providers: providers
                    )
                }
                
            }
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Send"
        
    }
    
}

