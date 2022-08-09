//
//  CourierUserViewController.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/8/22.
//

import UIKit
import Courier

class CourierUserViewController: UIViewController {

    @IBOutlet weak var userIdField: UITextField!
    @IBAction func userIdFieldChanged(_ sender: Any) {
        currentUserId = userIdField.text ?? ""
    }
    
    @IBOutlet weak var accessTokenField: UITextField!
    @IBAction func accessTokenFieldChanged(_ sender: Any) {
        currentAccessToken = accessTokenField.text ?? ""
    }
    
    @IBOutlet weak var authButton: ActionButton!
    
    @IBOutlet weak var buttonBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Courier User Details"
        
        userIdField.text = currentUserId
        accessTokenField.text = currentAccessToken
        
        refreshUI()
        authButton.action = { [weak self] in
            self?.authAction()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            buttonBottom.constant = -keyboardHeight
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        buttonBottom.constant = -20
    }

}

extension CourierUserViewController {
    
    private func refreshUI() {
        
        let isUserSignedIn = Courier.shared.userId != nil
        authButton.title = isUserSignedIn ? "Sign Out" : "Sign In"
        
        userIdField.isEnabled = !isUserSignedIn
        accessTokenField.isEnabled = !isUserSignedIn
        
        let alpha = !isUserSignedIn ? 1 : 0.5
        userIdField.alpha = alpha
        accessTokenField.alpha = alpha
        
        if (isUserSignedIn) {
            userIdField.resignFirstResponder()
            accessTokenField.resignFirstResponder()
        } else {
            userIdField.becomeFirstResponder()
        }
        
    }
    
    private func authAction() {
        if (Courier.shared.userId != nil) {
            signOut()
        } else {
            signIn()
        }
    }

    private func signOut() {

        Task {
            try await Courier.shared.signOut()
            refreshUI()
        }

    }

    private func signIn() {

        Task {
            
            authButton.title = "Loading..."

            // Courier needs you to generate an access token on your backend
            // Docs for setting this up: https://www.courier.com/docs/reference/auth/issue-token/
//            let accessToken = try await YourBackend.generateCourierAccessToken(userId: user.id)

            try await Courier.shared.setCredentials(
                accessToken: currentAccessToken,
                userId: currentUserId
            )

            refreshUI()
            
            if (Courier.shared.userId != nil) {
                self.navigationController?.popViewController(animated: true)
            }

        }

    }
    
}
