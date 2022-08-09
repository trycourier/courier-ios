//
//  NotificationPermissionViewController.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/8/22.
//

import UIKit
import Courier

class NotificationPermissionViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var settingButton: ActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notification Permission"
        
        refresh()
        
    }

}

extension NotificationPermissionViewController {
    
    private func updateUIForStatus(status: UNAuthorizationStatus) {
        
        if (status == .notDetermined) {
            messageLabel.text = status.prettyText
            settingButton.title = "Request Notification Permission"
            settingButton.action = { [weak self] in
                self?.requestAccess()
            }
        } else {
            messageLabel.text = status.prettyText + "\n\nOpen app settings to change the notification permission"
            settingButton.title = "Open app settings"
            settingButton.action = { [weak self] in
                self?.goToSettings()
            }
        }
        
    }
    
    private func refresh() {

        Task {
            
            settingButton.title = "Loading..."
            settingButton.isUserInteractionEnabled = false

            let status = try await Courier.getNotificationAuthorizationStatus()
            updateUIForStatus(status: status)
            
            settingButton.isUserInteractionEnabled = true

        }

    }
    
    private func requestAccess() {
        
        Task {
            
            settingButton.isUserInteractionEnabled = false

            let status = try await Courier.requestNotificationPermissions()
            updateUIForStatus(status: status)
            
            settingButton.isUserInteractionEnabled = true

        }
        
    }
    
    private func goToSettings() {
        Courier.openSettingsForApp()
    }
    
}
