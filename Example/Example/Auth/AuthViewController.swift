//
//  AuthViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/1/23.
//

import UIKit
import Courier_iOS
import ShowTime

class AuthViewController: UIViewController {
    
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var showTouchesSwitch: UISwitch!
    @IBAction func showTouchesAction(_ sender: Any) {
        ShowTime.enabled = showTouchesSwitch.isOn ? .always : .never
    }
    
    private var authListener: CourierAuthenticationListener? = nil
    
    @IBAction func authButtonAction(_ sender: Any) {
        
        if let _ = Courier.shared.userId {
            
            Task {
                
                self.authButton.isEnabled = false
            
                try await Courier.shared.signOut()
                
            }
            
        } else {
            
            showInputAlert(title: "Sign in", placeHolder: "Enter Courier User Id", action: "Sign In") { userId in
                
                Task {
                    
                    self.authButton.isEnabled = false
                    
                    let jwt = try await ExampleServer().generateJwt(
                        authKey: Env.COURIER_AUTH_KEY,
                        userId: userId
                    )
                    
                    try await Courier.shared.signIn(
                        accessToken: jwt,
                        userId: userId
                    )
                    
                }
                
            }
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Auth"
        
        ShowTime.enabled = .never
        showTouchesSwitch.setOn(ShowTime.enabled == .always, animated: false)

        Task {
            
            if let userId = Courier.shared.userId {
                
                self.authButton.isEnabled = false
                self.authLabel.text = "Refreshing JWT..."
                
                // Remove the existing user
                try await Courier.shared.signOut()
                
                // Get the JWT
                let jwt = try await ExampleServer().generateJwt(
                    authKey: Env.COURIER_AUTH_KEY,
                    userId: userId
                )
                
                // Sign in with JWT
                try await Courier.shared.signIn(
                    accessToken: jwt,
                    userId: userId
                )
                
                self.refresh(userId)
                
            }
            
            authListener = Courier.shared.addAuthenticationListener { [weak self] userId in
                self?.refresh(userId)
            }
            
        }
        
    }
    
    private func refresh(_ userId: String?) {
        
        if let userId = userId {
            authButton.setTitle("Sign Out", for: .normal)
            authLabel.text = "Courier User Id: \(userId)"
        } else {
            authButton.setTitle("Sign In", for: .normal)
            authLabel.text = "No Courier User Id Found"
        }
        
        authButton.isEnabled = true
        
    }
    
    deinit {
        authListener?.remove()
    }

}
