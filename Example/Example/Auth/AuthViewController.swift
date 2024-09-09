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
    @IBOutlet weak var showTouchesLabel: UILabel!
    @IBOutlet weak var showTouchesSwitch: UISwitch!
    @IBAction func showTouchesAction(_ sender: Any) {
        ShowTime.enabled = showTouchesSwitch.isOn ? .always : .never
    }
    
    private var authListener: CourierAuthenticationListener? = nil
    
    @IBAction func authButtonAction(_ sender: Any) {
        
        if let _ = Courier.shared.userId {
            
            self.authButton.isEnabled = false
            
            Task {
            
                await Courier.shared.signOut()
                
            }
            
        } else {
            
            showInputAlert(title: "Sign in", inputs: ["Enter Courier User Id", "Tenant Id"], action: "Sign In") { values in
                
                self.authButton.isEnabled = false
                
                Task {
                    
                    do {
                        
                        let userId = values[0]
                        let tenantId = values[1]
                        
                        let jwt = try await ExampleServer().generateJwt(
                            authKey: Env.COURIER_AUTH_KEY,
                            userId: userId
                        )
                        
                        await Courier.shared.signIn(
                            userId: userId,
                            tenantId: tenantId.isEmpty ? nil : tenantId,
                            accessToken: jwt
                        )
                        
                    } catch {
                        
                        await Courier.shared.signOut()
                        
                    }
                    
                }
                
            }
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Auth"
        
        ShowTime.enabled = .never
        showTouchesSwitch.setOn(ShowTime.enabled == .always, animated: false)
        
        let mono = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        authLabel.font = mono
        showTouchesLabel.font = mono

        Task {
            
            if let userId = Courier.shared.userId {
                
                do {
                    
                    self.authButton.isEnabled = false
                    self.authLabel.text = "Refreshing JWT..."
                    
                    // Remove the existing user
                    await Courier.shared.signOut()
                    
                    // Get the JWT
                    let jwt = try await ExampleServer().generateJwt(
                        authKey: Env.COURIER_AUTH_KEY,
                        userId: userId
                    )
                    
                    // Sign in with JWT
                    await Courier.shared.signIn(
                        userId: userId,
                        tenantId: Courier.shared.tenantId,
                        accessToken: jwt
                    )
                    
                    self.refresh(userId)
                    
                } catch {
                    
                    print(error.localizedDescription)
                    
                    self.refresh(nil)
                    
                }
                
            }
            
            authListener = Courier.shared.addAuthenticationListener { [weak self] userId in
                self?.refresh(userId)
            }
            
        }
        
    }
    
    private func refresh(_ userId: String?) {
        
        if let userId = userId {
            authButton.setTitle("Sign Out", for: .normal)
            authLabel.text = "Courier User Id: \(userId)\n\nTenant Id: \(Courier.shared.tenantId ?? "None")"
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
