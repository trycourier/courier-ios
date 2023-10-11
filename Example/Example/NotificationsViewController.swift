//
//  NotificationsViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 11/17/22.
//

import UIKit
import Courier_iOS

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var apnsSwitch: UISwitch!
    @IBOutlet weak var fcmSwitch: UISwitch!
    @IBOutlet weak var inboxSwitch: UISwitch!
    
    @IBAction func sendPushAction(_ sender: Any) {
        
        Task {

            let titles = [
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
                "Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore ",
                "Ullamco laboris nisi ut aliquip ex ea commodo consequat nisi ut aliquip ex ea commodo consequat duis aute irure dolor",
                "Lorem qui officia deserunt mollit anim id est laborum."
            ]

            let messages = [
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco",
                "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                "Lorem ipsum dolor sit amet"
            ]

            let title = titles.randomElement()!
            let body = messages.randomElement()!

            var providers: [String] = []

            if (apnsSwitch.isOn) {
                providers.append("apn")
            }

            if (fcmSwitch.isOn) {
                providers.append("firebase-fcm")
            }

            if (inboxSwitch.isOn) {
                providers.append("inbox")
            }

            if let userId = Courier.shared.userId {

                if (!providers.isEmpty) {
                    
                    let _ = try await ExampleServer().sendTest(
                        authKey: Env.COURIER_AUTH_KEY,
                        userId: userId,
                        providers: providers,
                        title: title,
                        body: body
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

