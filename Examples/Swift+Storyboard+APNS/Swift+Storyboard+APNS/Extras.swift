//
//  Extras.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/25/22.
//

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
            alert!.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                // Empty
            }))
            window.rootViewController?.present(alert!, animated: true, completion: nil)
        }
        
    }
    
}

extension UIViewController {
    
    func showInputAlert(title: String = "Configure SDK", action: String = "Save", fields: [UserDefaultKey]) async throws {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
          
            let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
            
            let textFields: [UITextField] = fields.map { key in
                var textField = UITextField()
                alert.addTextField { alertTextField in
                    alertTextField.placeholder = key.rawValue
                    textField = alertTextField
                    textField.text = getDefault(key: key)
                }
                return textField
            }
          
            let action = UIAlertAction(title: action, style: .default) { action in
                
                for (index, textField) in textFields.enumerated() {
                    let value = textField.text ?? ""
                    let key = fields[index]
                    setDefault(key: key, value: value)
                }
                
                continuation.resume()
                
            }
          
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
        })
        
    }
    
}

func setDefault(key: UserDefaultKey, value: String) {
    let defaults = UserDefaults.standard
    defaults.set(value, forKey: key.rawValue)
}

func getDefault(key: UserDefaultKey) -> String {
    let defaults = UserDefaults.standard
    return defaults.string(forKey: key.rawValue) ?? ""
}
