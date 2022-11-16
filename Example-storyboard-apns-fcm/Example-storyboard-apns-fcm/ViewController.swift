//
//  ViewController.swift
//  Example-storyboard-apns-fcm
//
//  Created by Fahad Amin on 11/11/22.
//

import UIKit
import Courier

class ViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sendPushButton: UIButton!
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        // Do any additional setup after loading the view.
    }

    @IBAction func authButtonAction(_ sender: UIButton) {
        Task{
            if let _ = Courier.shared.userId{
                try await Courier.shared.signOut()
                refresh()
            }
            else {
                try await Courier.shared.signIn(accessToken: Env.COURIER_ACCESS_TOKEN, userId: Env.COURIER_USER_ID)
                refresh()
                try await Courier.requestNotificationPermission()
            }
        }

    }
    
    @IBAction func sendPushButtonAction(_ sender: UIButton) {
        Task{
            let isApns = segmentedControl.selectedSegmentIndex == 0
            
            try await Courier.shared.sendPush(
                authKey: Env.COURIER_AUTH_KEY,
                userId: Env.COURIER_USER_ID,
                title: "\(isApns ? "APNS" : "FCM") Test Push",
                message: "Hello from Courier \(Env.COURIER_USER_ID)! 👋",
                isProduction: false,
                providers: [isApns ? .apns : .fcm]
            )
        }
        
    }
    private func refresh(){
        if let userId = Courier.shared.userId{
            authButton.setTitle("Sign Out", for: .normal)
            authLabel.text = "Courier User Id: \(userId)"
            sendPushButton.isHidden = false
            segmentedControl.isHidden = false
        }else{
            authButton.setTitle("Sign In", for: .normal)
            authLabel.text = "No Courier User Id Found"
            sendPushButton.isHidden = true
            segmentedControl.isHidden = true
        }
    }
}


