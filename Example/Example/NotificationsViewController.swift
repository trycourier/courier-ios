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
            
            var providers: [CourierChannel] = []
            
            if (apnsSwitch.isOn) {
                
                let channel = ApplePushNotificationsServiceChannel(
                    aps: [
                        "alert": [
                            "title": title,
                            "body": body
                        ],
                        "sound": "ping.aiff",
                        "badge": 123,
                        "CUSTOM_NUMBER": 456,
                        "CUSTOM_BOOLEAN": true,
                        "CUSTOM_KEY": "YOUR_CUSTOM_VALUE"
                    ]
                )
                
                providers.append(channel)
                
            }
            
            if (fcmSwitch.isOn) {
                
                let channel = FirebaseCloudMessagingChannel(
                    data: [
                        "FCM_CUSTOM_KEY": "YOUR_CUSTOM_VALUE",
                    ],
                    aps: [
                        "sound": "ping.aiff",
                        "badge": 123,
                        "APNS_CUSTOM_NUMBER": 456,
                        "APNS_CUSTOM_BOOLEAN": true,
                        "APNS_CUSTOM_KEY": "YOUR_CUSTOM_VALUE"
                    ]
                )
                
                providers.append(channel)
                
            }
            
            if (inboxSwitch.isOn) {
                
                let channel = CourierInboxChannel(
                    elements: [
                        CourierElement(
                            type: "action",
                            content: "Button 1",
                            data: [
                                "CUSTOM_KEY": "YOUR_CUSTOM_VALUE"
                            ]
                        ),
                        CourierElement(
                            type: "action",
                            content: "Button 2",
                            data: [
                                "CUSTOM_KEY": "YOUR_CUSTOM_VALUE"
                            ]
                        )
                    ]
                )
                
                providers.append(channel)
                
            }
            
            if let userId = Courier.shared.userId {
                
                if (!providers.isEmpty) {
                    try await Courier.shared.sendMessage(
                        authKey: Env.COURIER_AUTH_KEY,
                        userIds: [userId],
                        title: title,
                        body: body,
                        channels: providers
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

