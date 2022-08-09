//
//  FirebaseConfigViewController.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/9/22.
//

import UIKit
import FirebaseCore
import Courier

class FirebaseConfigViewController: UIViewController {
    
    @IBOutlet weak var appIdField: UITextField!
    @IBOutlet weak var gcmSenderIdField: UITextField!
    @IBOutlet weak var apiKeyField: UITextField!
    @IBOutlet weak var projectIdField: UITextField!
    @IBOutlet weak var clientIdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Firebase Configuration"
        
        guard let options = FirebaseApp.app()?.options else {
            return
        }
        
        appIdField.text = options.googleAppID
        gcmSenderIdField.text = options.gcmSenderID
        apiKeyField.text = options.apiKey
        projectIdField.text = options.projectID
        clientIdField.text = options.clientID
        
        refresh()
        
    }

}

extension FirebaseConfigViewController {
    
    private func refresh() {
        
        let fields = [appIdField, gcmSenderIdField, apiKeyField, projectIdField, clientIdField]
        fields.forEach { field in
            field?.isEnabled = false
            field?.alpha = 0.5
        }
        
    }
    
}
