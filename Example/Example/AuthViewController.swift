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
                    
                    do {
                        
//                        try await Courier.shared.signIn(
//                            accessToken: Env.COURIER_ACCESS_TOKEN,
//                            clientKey: Env.COURIER_CLIENT_KEY,
//                            userId: userId
//                        )
                        
                        try await Courier.shared.signIn(
                            accessToken: Env.COURIER_ACCESS_TOKEN,
                            userId: userId
                        )
                        
                        self.refresh()
                        try await Courier.requestNotificationPermission()
                        
                    } catch {
                        
                        if let e = error as? CourierError {
                            
                            var message = ""
                            
                            switch (e) {
                            case .noAccessTokenFound:
                                message = "No user found"
                            case .noUserIdFound:
                                message = "No user found"
                            case .requestError:
                                message = "An error occurred. Please try again."
                            case .requestParsingError:
                                message = "An error occurred data from server. Please try again."
                            case .sendTestMessageFail:
                                message = "An error occurred sending a test message."
                            case .inboxWebSocketError:
                                message = "An error occurred. Please try again."
                            case .inboxWebSocketFail:
                                message = "An error occurred. Please try again."
                            case .inboxWebSocketDisconnect:
                                message = "An error occurred. Please try again."
                            case .inboxUserNotFound:
                                message = "No user found"
                            case .inboxUnknownError:
                                message = "Unknown Courier Inbox error occurred. Please try again."
                            case .inboxNotInitialized:
                                message = "The Courier Inbox is not setup. Please add a CourierInbox view or call Courier.shared.addInboxListener"
                            case .inboxMessageNotFound:
                                message = "Courier Inbox message not found"
                            }
                            
                            self.showInputAlert(title: message, placeHolder: message, action: error.localizedDescription, onComplete: { test in
                                print(test)
                            })
                        }
                        
                    }
                    
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
