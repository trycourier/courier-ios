//
//  RootViewController.swift
//  Demo
//
//  Created by Michael Miller on 8/9/22.
//

import UIKit
import Courier
import FirebaseCore
import FirebaseMessaging

class RootViewController: UIViewController {

    @IBOutlet weak var sendTestButton: ActionButton!
    @IBOutlet weak var notificationActionButton: ActionButton!
    @IBOutlet weak var userDetailsActionButton: ActionButton!
    @IBOutlet weak var firebaseActionButton: ActionButton!
    
    @IBOutlet weak var providerSegment: UISegmentedControl!
    @IBAction func providerChange(_ sender: Any) {
        updateMessagingUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Courier Demo"
        
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
        updateMessagingUI()
    }

}

// MARK: Notifications Setup

extension RootViewController {
    
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

extension RootViewController {
    
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

extension RootViewController {
    
    var isFirebase: Bool {
        get {
            return providerSegment.selectedSegmentIndex == 1
        }
    }
    
    private func updateMessagingUI() {
        
        firebaseActionButton.isHidden = !isFirebase
        
        sendTestButton.title = isFirebase ? "Send FCM Test Push" : "Send APNS Test Push"
        
        var rows = [ActionButton.Row(title: "Firebase Configuration", value: nil)]
        
        guard let options = FirebaseApp.app()?.options else {
            firebaseActionButton.rows = rows
            return
        }
        
        rows.append(ActionButton.Row(title: "Google App Id", value: options.googleAppID))
        rows.append(ActionButton.Row(title: "GCM Sender Id", value: options.gcmSenderID))
        firebaseActionButton.rows = rows
        
    }
    
}

// MARK: Test Push Setup

extension RootViewController {
    
    private func setMessagingButton(isLoading: Bool) {
        
        if (isLoading) {
            sendTestButton.title = "Loading..."
        } else {
            updateMessagingUI()
        }
        
        sendTestButton.isUserInteractionEnabled = !isLoading

    }
    
    private func sendTestMessage() {
        
        Task {
            
            do {
                
                // Request push notifications if they are not requested
                let status = try await Courier.requestNotificationPermissions()
                updateUIForStatus(status: status)
                
                // Check for user
                if (Courier.shared.userId == nil) {
                    appDelegate.showMessageAlert(
                        title: "Courier user not set",
                        message: "Set your Courier credentials before sending a push",
                        onOkClick: {
                            let vc = CourierUserViewController()
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    )
                    return
                }
                
                setMessagingButton(isLoading: true)
                
                // Sync fcm token if possible
                if let fcmToken = Messaging.messaging().fcmToken {
                    try await Courier.shared.setPushToken(
                        provider: .fcm,
                        token: fcmToken
                    )
                    refreshUser()
                }
                
                let provider = isFirebase ? CourierProvider.fcm : CourierProvider.apns
                let userId = Courier.shared.userId ?? ""
                
                // Send the test
                try await Courier.sendPush(
                    authKey: currentAccessToken, // TODO: Remove this from production
                    userId: userId,
                    title: "Hi \(userId) 👋",
                    message: "This is a message from \(provider == .apns ? "APNS 🍎" : "FCM 🔥")",
                    providers: [provider]
                )
                
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
