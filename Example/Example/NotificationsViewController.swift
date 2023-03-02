//
//  NotificationsViewController.swift
//  Example
//
//  Created by Michael Miller on 11/17/22.
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
            
            let messageProviders = providers.map { $0.rawValue }.joined(separator: " and ")
            
            if let userId = Courier.shared.userId {
                
                if (!providers.isEmpty) {
                    try await Courier.shared.sendMessage(
                        authKey: Env.COURIER_AUTH_KEY,
                        userId: userId,
                        title: "Hey \(userId)!",
                        message: randomText(),
                        providers: providers
                    )
                }
                
            }
            
        }
        
    }
    
    func randomText() -> String{
        let paragraph = Int.random(in: 1..<20)
        var global = ""
        for _ in 0..<(Int.random(in: 2..<paragraph)) {
            var x = ""
            for _ in 0..<Int.random(in: 2..<15){
                let string = String(format: "%c", Int.random(in: 97..<123)) as String
                x+=string
            }
            global = global +  " " + x
        }
        return global
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Send"
        
    }
    
}

