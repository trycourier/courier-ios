//
//  AuthViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/1/23.
//

import UIKit
import Courier_iOS

class AuthViewController: UIViewController {
    
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    
    @IBAction func authButtonAction(_ sender: Any) {
        
        if let _ = Courier.shared.userId {
            
            Task {
            
                try await Courier.shared.signOut()
                refresh()
                
            }
            
        } else {
            
            showInputAlert(title: "Sign in", placeHolder: "Enter Courier User Id", action: "Sign In") { userId in
                
                Task {
                    
                    try await Courier.shared.signIn(
                        accessToken: Env.COURIER_ACCESS_TOKEN,
                        clientKey: Env.COURIER_CLIENT_KEY,
                        userId: userId
                    )
                    
                    self.refresh()
                    try await Courier.requestNotificationPermission()
                    
                }
                
            }
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Auth"

        refresh()
        
    }
    
    private func refresh() {
        
        if let userId = Courier.shared.userId {
            
            authButton.setTitle("Sign Out", for: .normal)
            authLabel.text = "Courier User Id: \(userId)"
            
        } else {
            
            authButton.setTitle("Sign In", for: .normal)
            authLabel.text = "No Courier User Id Found"
            
        }
        
    }

}
