//
//  FirebaseConfigViewController.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/9/22.
//

import UIKit
import Courier
import FirebaseCore
import FirebaseMessaging

class FirebaseConfigViewController: UIViewController {
    
    @IBOutlet weak var actionButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var actionButton: ActionButton!
    
    @IBOutlet weak var appIdField: UITextField!
    @IBAction func appIdFieldChange(_ sender: Any) {
        firebaseGoogleAppId = appIdField.text ?? ""
    }
    
    @IBOutlet weak var gcmSenderIdField: UITextField!
    @IBAction func gcmSenderIdFieldChange(_ sender: Any) {
        firebaseGcmSenderId = gcmSenderIdField.text ?? ""
    }
    
    @IBOutlet weak var apiKeyField: UITextField!
    @IBAction func apiKeyFieldChange(_ sender: Any) {
        firebaseApiKey = apiKeyField.text ?? ""
    }
    
    @IBOutlet weak var projectIdField: UITextField!
    @IBAction func projectIdFieldChange(_ sender: Any) {
        firebaseProjectId = projectIdField.text ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Firebase Configuration"
        
        appIdField.text = firebaseGoogleAppId
        gcmSenderIdField.text = firebaseGcmSenderId
        apiKeyField.text = firebaseApiKey
        projectIdField.text = firebaseProjectId
        
        refresh()
        
        actionButton.action = { [weak self] in
            if (FirebaseApp.app() == nil) {
                self?.configure()
            } else {
                self?.deconfigure()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            actionButtonBottom.constant = keyboardHeight
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        actionButtonBottom.constant = 20
    }

}

extension FirebaseConfigViewController {
    
    private func refresh() {
        
        let noFirebase = FirebaseApp.app() == nil
        
        let fields = [appIdField, gcmSenderIdField, apiKeyField, projectIdField]
        fields.forEach { field in
            field?.isEnabled = noFirebase
            field?.alpha = noFirebase ? 1 : 0.5
            field?.resignFirstResponder()
        }
        
        if (noFirebase) {
            appIdField.becomeFirstResponder()
        }
        
        actionButton.title = noFirebase ? "Configure Firebase" : "Remove Firebase"
        
    }
    
    private func deconfigure() {
        if let app = FirebaseApp.app() {
            app.delete { [weak self] _ in
                self?.refresh()
            }
        }
    }
    
    private func configure() {
        
        deconfigure()
        
        firebaseGoogleAppId = appIdField.text ?? ""
        firebaseGcmSenderId = gcmSenderIdField.text ?? ""
        firebaseApiKey = apiKeyField.text ?? ""
        firebaseProjectId = projectIdField.text ?? ""
        
        let options = FirebaseOptions(
            googleAppID: firebaseGoogleAppId,
            gcmSenderID: firebaseGcmSenderId
        )
        options.projectID = firebaseProjectId
        options.apiKey = firebaseApiKey
        
        FirebaseApp.configure(options: options)
        
        if let token = Courier.shared.rawApnsToken {
            print([UInt8](token))
            Messaging.messaging().setAPNSToken(token, type: .sandbox)
        }
        
        refresh()
        
        navigationController?.popViewController(animated: true)
        
    }
    
}
