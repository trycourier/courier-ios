//
//  ViewController.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 7/21/22.
//

import UIKit
import Courier

class ViewController: UIViewController {

    @IBOutlet weak var sendTestButton: ActionButton!
    @IBOutlet weak var notificationActionButton: ActionButton!
    @IBOutlet weak var userDetailsActionButton: ActionButton!
    @IBOutlet weak var firebaseActionButton: ActionButton!
    @IBOutlet weak var providerSegment: UISegmentedControl!
    
    @IBAction func providerChange(_ sender: Any) {
        updateFirebaseUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Courier Example"
        
        notificationActionButton.action = { [weak self] in
            let vc = NotificationPermissionViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        userDetailsActionButton.action = { [weak self] in
            let vc = CourierUserViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        firebaseActionButton.action = { [weak self] in
            let vc = FirebaseConfigViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        sendTestButton.action = { [weak self] in
            self?.sendTestMessage()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUser()
        refreshNotificationPermission()
        setMessagingButton(isLoading: false)
        updateFirebaseUI()
    }

}

// MARK: Notifications Setup

extension ViewController {
    
    private func updateUIForStatus(status: UNAuthorizationStatus) {
        
        notificationActionButton.rows = [
            ActionButton.Row(title: "Notification Permission", value: nil),
            ActionButton.Row(title: "Status", value: status.prettyText)
        ]
        
    }
    
    private func refreshNotificationPermission() {
        
        let row = ActionButton.Row(title: "Getting notification status...", value: nil)
        notificationActionButton.rows = [row]

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

// MARK: Example Authentication Setup

extension ViewController {
    
    private func refreshUser() {
        
        var rows = [
            ActionButton.Row(title: "Courier Credentials", value: nil)
        ]
        
        if (Courier.shared.userId != nil) {
            rows.append(ActionButton.Row(title: "User ID", value: Courier.shared.userId ?? "Not set"))
            rows.append(ActionButton.Row(title: "Access Token", value: currentAccessToken))
            rows.append(ActionButton.Row(title: "APNS Token", value: Courier.shared.apnsToken ?? "Not set"))
            rows.append(ActionButton.Row(title: "FCM Token", value: Courier.shared.fcmToken ?? "Not set"))
        } else {
            rows.append(ActionButton.Row(title: "User Status", value: "Not Signed In"))
        }
        
        userDetailsActionButton.rows = rows
        
    }
    
}

// MARK: Firebase Setup

extension ViewController {
    
    private func updateFirebaseUI() {
        
        let isFirebase = providerSegment.selectedSegmentIndex == 1
        
        let row = ActionButton.Row(title: "Firebase Settings", value: nil)
        firebaseActionButton.rows = [row]
        
        firebaseActionButton.isHidden = !isFirebase
        
    }
    
}

// MARK: Test Push Setup

extension ViewController {
    
    private func setMessagingButton(isLoading: Bool) {
        sendTestButton.title = isLoading ? "Loading..." : "Send Test Push Notification"
        sendTestButton.isUserInteractionEnabled = !isLoading
    }
    
    private func sendTestMessage() {
        
        Task {
            
            setMessagingButton(isLoading: true)
            
            do {
                
                // Request push notifications if they are not requested
                let status = try await Courier.requestNotificationPermissions()
                updateUIForStatus(status: status)
                
                // Send the test
                try await Courier.sendPush(
                    authKey: currentAccessToken, // TODO: Remove this from production
                    userId: currentUserId,
                    title: "Chirp Chirp!",
                    message: "This is a test message sent from the Courier iOS APNS example app"
                )
                
                // Check if Courier has a user already signed in
                if (Courier.shared.userId == nil) {
                    appDelegate.showMessageAlert(
                        title: "You are not signed in",
                        message: "Courier will try and send push notifications to this user id, but you will not receive them on this device."
                    )
                }
                
            } catch {
                
                appDelegate.showMessageAlert(
                    title: "Error sending test push",
                    message: "\(error)"
                )
                
            }
            
            setMessagingButton(isLoading: false)
            
        }
        
    }
    
}
