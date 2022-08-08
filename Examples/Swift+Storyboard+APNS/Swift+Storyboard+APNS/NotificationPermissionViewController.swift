//
//  NotificationPermissionViewController.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/8/22.
//

import UIKit

class NotificationPermissionViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBAction func buttonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notification Permission"
        
    }

}
