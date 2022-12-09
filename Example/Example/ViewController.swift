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
        
        Task {
            
            if let _ = Courier.shared.userId {
                
                try await Courier.shared.signOut()
                refresh()
                
            } else {
                
                let alert = UIAlertController(
                    title: "Sign In with Courier User Id",
                    message: "Please enter Courier User Id to continue.",
                    preferredStyle: .alert
                )
                present(alert, animated: true)
                
                alert.addTextField{ field in
                    field.placeholder = "Courier User Id"
                    field.keyboardType = .default
                    field.autocorrectionType = .no
                    field.autocapitalizationType = .none
                    field.returnKeyType = .continue
                }
                
                alert.addAction(UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil
                ))
                
                alert.addAction(UIAlertAction(
                    title: "Sign In",
                    style: .default,
                    handler: {_ in
                        
                        guard let fields = alert.textFields, fields.count == 1 else {
                            return
                        }
                        let userIdField = fields[0]
                        
                        guard let userId = userIdField.text, !userId.isEmpty else{
                           return
                        }
                        
                        Task{
                            try await Courier.shared.signIn(
                                accessToken: Env.COURIER_ACCESS_TOKEN,
                                userId: userId
                            )
                            
                            self.refresh()
                        
                            try await Courier.requestNotificationPermission()
                        }
                       
                    }
                ))

                
            }
            
        }
        
    }
    
    @IBAction func sendPushAction(_ sender: Any) {
        
        Task {
            
            var providers: [CourierProvider] = []
            
            if (apnsSwitch.isOn) {
                providers.append(.apns)
            }
            
            if (fcmSwitch.isOn) {
                providers.append(.fcm)
            }
            
            let messageProviders = providers.map { $0.rawValue }.joined(separator: " and ")
            
            if let userId = Courier.shared.userId {
                
                if (!providers.isEmpty) {
                    try await Courier.shared.sendPush(
                        authKey: Env.COURIER_AUTH_KEY,
                        userId: userId,
                        title: "Hey \(userId)!",
                        message: "This is a test push sent through \(messageProviders)",
                        isProduction: false,
                        providers: providers
                    )
                }
                
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
            
        } else {
            
            authButton.setTitle("Sign In", for: .normal)
            authLabel.text = "No Courier User Id Found"
            sendButton.isEnabled = false
            
        }
        
    }
    
}

