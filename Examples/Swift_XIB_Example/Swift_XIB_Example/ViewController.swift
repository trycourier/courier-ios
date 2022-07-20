//
//  ViewController.swift
//  Swift_XIB_Example
//
//  Created by Michael Miller on 7/20/22.
//

import UIKit
import Courier

class ViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshUser()
        refreshNotificationPermission()
        
    }

}

// MARK: Example Authentication Setup

extension ViewController {
    
    private func refreshUser() {
        if (Courier.shared.user != nil) {
            userStatusLabel.text = "User is signed in:\n\(Courier.shared.user!.id)"
            userStatusButton.setTitle("Sign Out", for: .normal)
        } else {
            userStatusLabel.text = "User is signed out"
            userStatusButton.setTitle("Sign In", for: .normal)
        }
    }
    
    private func performUserButtonAction() {
        if (Courier.shared.user != nil) {
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
        
        let randomId = UUID().uuidString
        
        let address = CourierAddress(
            formatted: "some_format",
            street_address: "1234 Fake Street",
            locality: "en-us",
            region: "east",
            postal_code: "55555",
            country: "us"
        )
        
        Courier.shared.user = CourierUser(
            id: randomId,
            email: "example@email.com",
            email_verified: false,
            phone_number: "5555555555",
            phone_number_verified: false,
            picture: "something.com",
            birthdate: "1/23/4567",
            gender: "gender",
            profile: "profile_name",
            sub: "sub",
            name: "Name",
            nickname: "Nickname",
            preferred_name: "Preferred Name",
            preferred_username: "Preferred Username",
            given_name: "Given Name",
            middle_name: "Middle Name",
            family_name: "Family Name",
            first_name: "First Name",
            last_name: "Last Name",
            website: "Website",
            locale: "Locale",
            zoneinfo: "Zoneinfo",
            updated_at: "Updated at now",
            address: address
        )
        
        refreshUser()
        
    }
    
}

// MARK: Example Notifications Setup

extension ViewController {
    
    private func updateUIForStatus(status: UNAuthorizationStatus) {
        
        notificationStatusLabel.text = "Notification Permission:\n\(status.prettyText)"
        
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

extension UNAuthorizationStatus {
    
    var prettyText: String {
        get {
            switch (self) {
            case .notDetermined:
                return "Not Determined"
            case .denied:
                return "Denied"
            case .authorized:
                return "Authorized"
            case .provisional:
                return "Provisional"
            case .ephemeral:
                return "Ephemeral"
            @unknown default:
                return "Unknown"
            }
        }
    }
    
}

