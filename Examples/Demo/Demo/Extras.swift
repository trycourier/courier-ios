//
//  Extras.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 7/21/22.
//

/**
 This code is only here for demo purposes
 You do not need to use this code in your app
 */

import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

extension UIApplication {
    var currentWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first
    }
}

var alert: UIAlertController? = nil

extension AppDelegate {
    
    func showMessageAlert(title: String, message: String) {
        
        alert?.dismiss(animated: true)
        
        if let window = UIApplication.shared.currentWindow {
            alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert!.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
            window.rootViewController?.present(alert!, animated: true, completion: nil)
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
