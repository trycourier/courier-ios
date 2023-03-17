//
//  Extras.swift
//  Example
//
//  Created by https://github.com/mikemilla on 11/17/22.
//

import UIKit
import Courier

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
            alert!.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                // Empty
            }))
            window.rootViewController?.present(alert!, animated: true, completion: nil)
        }
        
    }
    
}

extension UIViewController {
    
    func showInputAlert(title: String, placeHolder: String, action: String, onComplete: @escaping (String) -> Void) {
        
        alert?.dismiss(animated: true)
        
        alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )
        
        if let alert = alert {
            
            present(alert, animated: true)
            
            alert.addTextField { field in
                field.placeholder = placeHolder
                field.keyboardType = .default
                field.autocorrectionType = .no
                field.autocapitalizationType = .none
                field.returnKeyType = .continue
            }
            
            alert.addAction(UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            ))
            
            alert.addAction(UIAlertAction(
                title: action,
                style: .default,
                handler: { _ in
                    
                    let textField = alert.textFields?[0]
                    let text = textField?.text ?? ""
                    
                    if (text.isEmpty) {
                        return
                    }
                    
                    onComplete(text)
                   
                }
            ))
            
        }
        
    }
    
}

extension InboxMessage {
    
    func toJson() -> String {
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(self)
            return String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
        } catch {
            return "Error"
        }
        
    }
    
}
