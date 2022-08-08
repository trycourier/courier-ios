//
//  ViewController.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 7/21/22.
//

import UIKit
import Courier

class ViewController: UIViewController {
    
    let userId = "example_user"
    let authKey = "your_auth_key"

    @IBOutlet weak var userStatusLabel: UILabel!
    @IBOutlet weak var userStatusButton: UIButton!
    @IBAction func userButtonAction(_ sender: Any) {
        performUserButtonAction()
    }
    
    @IBOutlet weak var notificationStatusLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBAction func notificationRequestAction(_ sender: Any) {
        requestNotificationPermissions()
    }
    
    @IBOutlet weak var testMessageButton: UIButton!
    @IBAction func testMessageAction(_ sender: Any) {
        sendTestMessage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshUser()
        refreshNotificationPermission()
        
    }

}

// MARK: Example Authentication Setup

extension ViewController {
    
    private func refreshUser() {
        if (Courier.shared.userId != nil) {
            userStatusLabel.text = "Courier User Id is set to:\n\n\(Courier.shared.userId!)"
            userStatusButton.setTitle("Sign Out", for: .normal)
        } else {
            userStatusLabel.text = "No Courier User Id Found.\n\nClick 'Sign In' to sync APNS token to Courier"
            userStatusButton.setTitle("Sign In", for: .normal)
        }
    }
    
    private func performUserButtonAction() {
        if (Courier.shared.userId != nil) {
            signOutUser()
        } else {
            signInUser()
        }
    }
    
    private func signOutUser() {
        
        userStatusLabel.text = "Signing out..."
        userStatusButton.isHidden = true
        
        Task.init {
            try await Courier.shared.signOut()
            refreshUser()
            userStatusButton.isHidden = false
        }
        
    }
    
    private func signInUser() {
        
        Task.init {
            
            userStatusLabel.text = "Signing in..."
            userStatusButton.isHidden = true
            
            // Courier needs you to generate an access token on your backend
            // Docs for setting this up: https://www.courier.com/docs/reference/auth/issue-token/
//            let accessToken = try await YourBackend.generateCourierAccessToken(userId: user.id)
            
            // You can test with your auth key
            let accessToken = authKey
            
            try await Courier.shared.setCredentials(
                accessToken: accessToken,
                userId: userId
            )
            
            refreshUser()
            
            userStatusButton.isHidden = false
            
        }
        
    }
    
}

// MARK: Example Notifications Setup

extension ViewController {
    
    private func updateUIForStatus(status: UNAuthorizationStatus) {
        
        notificationStatusLabel.text = "Notification Permission:\n\n\(status.prettyText)"
        
        if (status == .notDetermined) {
            notificationButton.setTitle("Request Notification Permission", for: .normal)
            notificationButton.isHidden = false
        } else {
            notificationButton.isHidden = true
        }
        
    }
    
    private func refreshNotificationPermission() {
        
        notificationStatusLabel.text = "Getting notification status..."
        notificationButton.isHidden = true
        
        Task.init {
            
            let status = try await Courier.getNotificationAuthorizationStatus()
            updateUIForStatus(status: status)
            
        }
        
    }
    
    private func requestNotificationPermissions() {
        
        Task.init {
            
            let status = try await Courier.requestNotificationPermissions()
            updateUIForStatus(status: status)
            
        }
        
    }
    
}

// MARK: Example Test Push Setup

extension ViewController {
    
    private func sendTestMessage() {
        
        Task.init {
            
            testMessageButton.isEnabled = false
            
            // Request push notifications if they are not requested
            let status = try await Courier.requestNotificationPermissions()
            updateUIForStatus(status: status)
            
            // Send the test
            try await Courier.sendPush(
                authKey: authKey, // TODO: Remove this from production
                userId: userId,
                title: "Chirp Chirp!",
                message: "This is a test message sent from the Courier iOS APNS example app"
            )
            
            // Check if Courier has a user already signed in
            if (Courier.shared.userId == nil) {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showMessageAlert(
                    title: "You are not signed in",
                    message: "Courier will try and send push notifications to this user id, but you will not receive them on this device."
                )
            }
            
            testMessageButton.isEnabled = true
            
        }
        
    }
    
}
