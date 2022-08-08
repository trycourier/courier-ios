//
//  ViewController.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 7/21/22.
//

import UIKit
import Courier

class ViewController: UIViewController {

    @IBOutlet weak var notificationActionButton: ActionButton!
    @IBOutlet weak var userDetailsActionButton: ActionButton!
    
    @IBOutlet weak var userStatusLabel: UILabel!
    @IBOutlet weak var userStatusButton: UIButton!
    @IBAction func userButtonAction(_ sender: Any) {
//        performUserButtonAction()
    }
    
    @IBOutlet weak var notificationStatusLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBAction func notificationRequestAction(_ sender: Any) {
//        requestNotificationPermissions()
        let vc = NotificationPermissionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet weak var testMessageButton: UIButton!
    @IBAction func testMessageAction(_ sender: Any) {
//        Courier.openSettingsForApp()
//        sendTestMessage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Courier Example"
        
        notificationActionButton.action = { [weak self] in
            let vc = NotificationPermissionViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        userDetailsActionButton.action = { [weak self] in
            let vc = UserDetailsViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        refreshUser()
        refreshNotificationPermission()
        
    }

}

// MARK: Example Authentication Setup

extension ViewController {
    
    private func refreshUser() {
        
        userDetailsActionButton.rows = [
            ActionButton.Row(title: "Courier Credentials", value: ""),
            ActionButton.Row(title: "User ID", value: currentUserId ?? "Not set"),
            ActionButton.Row(title: "Access Token", value: currentAccessToken ?? "Not set"),
            ActionButton.Row(title: "Courier Credentials", value: ""),
            ActionButton.Row(title: "User ID", value: currentUserId ?? "Not set"),
            ActionButton.Row(title: "Access Token", value: currentAccessToken ?? "Not set"),
            ActionButton.Row(title: "Courier Credentials", value: ""),
            ActionButton.Row(title: "User ID", value: currentUserId ?? "Not set"),
            ActionButton.Row(title: "Access Token", value: currentAccessToken ?? "Not set"),
            ActionButton.Row(title: "Courier Credentials", value: ""),
            ActionButton.Row(title: "User ID", value: currentUserId ?? "Not set"),
            ActionButton.Row(title: "Access Token", value: currentAccessToken ?? "Not set"),
            ActionButton.Row(title: "Courier Credentials", value: ""),
            ActionButton.Row(title: "User ID", value: currentUserId ?? "Not set"),
            ActionButton.Row(title: "Access Token", value: currentAccessToken ?? "Not set"),
            ActionButton.Row(title: "Courier Credentials", value: ""),
            ActionButton.Row(title: "User ID", value: currentUserId ?? "Not set"),
            ActionButton.Row(title: "Access Token", value: currentAccessToken ?? "Not set"),
            ActionButton.Row(title: "Courier Credentials", value: ""),
            ActionButton.Row(title: "User ID", value: currentUserId ?? "Not set"),
            ActionButton.Row(title: "Access Token", value: currentAccessToken ?? "Not set")
        ]
        
//        if (Courier.shared.userId != nil) {
//
//            notificationActionButton.rows = [
//                ActionButton.Row(title: "Notification Permission", value: ""),
//                ActionButton.Row(title: "Status", value: status.prettyText)
//            ]
//
//            userStatusLabel.text = "Courier User Id is set to:\n\n\(Courier.shared.userId!)"
//            userStatusButton.setTitle("Sign Out", for: .normal)
//        } else {
//            userStatusLabel.text = "No Courier User Id Found.\n\nClick 'Sign In' to sync APNS token to Courier"
//            userStatusButton.setTitle("Sign In", for: .normal)
//        }
    }
    
//    private func performUserButtonAction() {
//        if (Courier.shared.userId != nil) {
//            signOutUser()
//        } else {
//            signInUser()
//        }
//    }
//
//    private func signOutUser() {
//
//        userStatusLabel.text = "Signing out..."
//        userStatusButton.isHidden = true
//
//        Task {
//            try await Courier.shared.signOut()
//            refreshUser()
//            userStatusButton.isHidden = false
//        }
//
//    }
//
//    private func signInUser() {
//
//        Task.init {
//
//            userStatusLabel.text = "Signing in..."
//            userStatusButton.isHidden = true
//
//            // Courier needs you to generate an access token on your backend
//            // Docs for setting this up: https://www.courier.com/docs/reference/auth/issue-token/
////            let accessToken = try await YourBackend.generateCourierAccessToken(userId: user.id)
//
//            // You can test with your auth key
////            let accessToken = authKey
//
//            try await Courier.shared.setCredentials(
//                accessToken: currentAccessToken ?? "",
//                userId: currentUserId ?? ""
//            )
//
//            refreshUser()
//
//            userStatusButton.isHidden = false
//
//        }
//
//    }
    
}

// MARK: Example Notifications Setup

extension ViewController {
    
    private func updateUIForStatus(status: UNAuthorizationStatus) {
        
        notificationActionButton.rows = [
            ActionButton.Row(title: "Notification Permission", value: ""),
            ActionButton.Row(title: "Status", value: status.prettyText)
        ]
        
//        if (status == .notDetermined) {
//            notificationButton.setTitle("Request Notification Permission", for: .normal)
//            notificationButton.isHidden = false
//        } else {
//            notificationButton.isHidden = true
//        }
        
    }
    
    private func refreshNotificationPermission() {
        
        let row = ActionButton.Row(title: "Getting notification status...", value: "")
        notificationActionButton.rows = [row]

//        notificationStatusLabel.text = "Getting notification status..."
//        notificationButton.isHidden = true

        Task {

            let status = try await Courier.getNotificationAuthorizationStatus()
            updateUIForStatus(status: status)

        }

    }
    
    private func requestNotificationPermissions() {
        
        Task {
            
            let status = try await Courier.requestNotificationPermissions()
            updateUIForStatus(status: status)
            
        }
        
    }
    
}

// MARK: Example Test Push Setup

extension ViewController {
    
    private func sendTestMessage() {
        
        Task {
            
            testMessageButton.isEnabled = false
            
            // Request push notifications if they are not requested
            let status = try await Courier.requestNotificationPermissions()
            updateUIForStatus(status: status)
            
            // Send the test
            try await Courier.sendPush(
                authKey: currentAccessToken ?? "", // TODO: Remove this from production
                userId: currentUserId ?? "",
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
