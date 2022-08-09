//
//  FirebaseConfigViewController.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/9/22.
//

import UIKit
import FirebaseCore

class FirebaseConfigViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseApp.configure(options: FirebaseOptions(googleAppID: <#T##String#>, gcmSenderID: <#T##String#>))
        
    }

}
