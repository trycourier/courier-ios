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
    
    func showMessageAlert(title: String, message: String, onOkClick: (() -> Void)? = nil) {
        
        alert?.dismiss(animated: true)
        
        if let window = UIApplication.shared.currentWindow {
            alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert!.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                onOkClick?()
            }))
            window.rootViewController?.present(alert!, animated: true, completion: nil)
        }
        
    }
    
}

extension UIViewController {
    
    func share(value: String) {
        let textToShare = [value]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
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

class LocalStorage {

    static var userId: String? {
        get {
            return UserDefaults.standard.string(forKey: "user.id")
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: "user.id")
            } else {
                UserDefaults.standard.removeObject(forKey: "user.id")
            }
        }
    }
    
    static var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "access.token")
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: "access.token")
            } else {
                UserDefaults.standard.removeObject(forKey: "access.token")
            }
        }
    }
    
    static var googleAppId: String? {
        get {
            return UserDefaults.standard.string(forKey: "fireabse.googleAppId")
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: "fireabse.googleAppId")
            } else {
                UserDefaults.standard.removeObject(forKey: "fireabse.googleAppId")
            }
        }
    }
    
    static var gcmSenderId: String? {
        get {
            return UserDefaults.standard.string(forKey: "fireabse.gcmSenderId")
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: "fireabse.gcmSenderId")
            } else {
                UserDefaults.standard.removeObject(forKey: "fireabse.gcmSenderId")
            }
        }
    }
    
    static var apiKey: String? {
        get {
            return UserDefaults.standard.string(forKey: "fireabse.apiKey")
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: "fireabse.apiKey")
            } else {
                UserDefaults.standard.removeObject(forKey: "fireabse.apiKey")
            }
        }
    }
    
    static var projectId: String? {
        get {
            return UserDefaults.standard.string(forKey: "fireabse.projectId")
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: "fireabse.projectId")
            } else {
                UserDefaults.standard.removeObject(forKey: "fireabse.projectId")
            }
        }
    }
    
}
