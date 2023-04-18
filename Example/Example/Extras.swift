//
//  Extras.swift
//  Example
//
//  Created by https://github.com/mikemilla on 11/17/22.
//

import UIKit
import Courier_iOS

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

extension InboxAction {
    
    func toJson() -> String? {
        
        let dictionary: [String: Any] = [
            "content": self.content ?? "",
            "href": self.href ?? "",
            "data": self.data ?? [:]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
        
    }
    
}

extension InboxMessage {
    
    func toJson() -> String? {
        
        let dictionary: [String: Any] = [
            "messageId": self.messageId,
            "title": self.title ?? "",
            "body": self.body ?? "",
            "preview": self.preview ?? "",
            "created": self.created ?? "",
            "read": self.isRead,
            "opened": self.isOpened,
            "archived": self.isArchived,
            "actions": actions?.map { action in
                return [
                    "content": action.content ?? "",
                    "href": action.href ?? "",
                    "data": action.data ?? [:]
                ]
            } ?? [],
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
        
    }
    
}

extension Dictionary where Key == AnyHashable, Value == Any {
    
    func toJson() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            print("Error converting dictionary to JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
}
