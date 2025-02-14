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
    
    func showCodeAlert(title: String, code: String) {
        alert?.dismiss(animated: true)
        
        if let window = UIApplication.shared.currentWindow {
            alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            
            // Create a scrollable text view for the code
            let messageTextView = UITextView()
            messageTextView.backgroundColor = .clear
            messageTextView.text = code
            messageTextView.isEditable = false
            messageTextView.isScrollEnabled = true
            messageTextView.translatesAutoresizingMaskIntoConstraints = false
            
            // Set monospaced font for the text view
            messageTextView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular) // Adjust font size as needed
            
            // Set text view height (adjust as needed)
            let textViewHeight: CGFloat = 300
            
            // Add the text view to the alert
            alert!.view.addSubview(messageTextView)
            
            // Define constraints for the text view
            NSLayoutConstraint.activate([
                messageTextView.topAnchor.constraint(equalTo: alert!.view.topAnchor, constant: 60), // Adjust constant as needed
                messageTextView.bottomAnchor.constraint(equalTo: alert!.view.bottomAnchor, constant: -45), // Adjust constant as needed
                messageTextView.leadingAnchor.constraint(equalTo: alert!.view.leadingAnchor, constant: 8),
                messageTextView.trailingAnchor.constraint(equalTo: alert!.view.trailingAnchor, constant: -8),
                messageTextView.heightAnchor.constraint(equalToConstant: textViewHeight)
            ])
            
            // Add the "OK" button
            alert!.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            // Present the alert
            window.rootViewController?.present(alert!, animated: true, completion: nil)
        }
    }

    
}

extension UIViewController {
    
    func showActionSheet(message: InboxMessage) async {
        
        let json = await message.toJson()
        let isRead = await message.isRead
        
        // Create the action sheet
        let actionSheet = UIAlertController(title: message.messageId, message: nil, preferredStyle: .actionSheet)
        
        // Add the first action
        let action1 = UIAlertAction(title: isRead ? "Unread Message" : "Read Message", style: .default) { _ in
            Task {
                do {
                    if isRead {
                        try await Courier.shared.unreadMessage(message.messageId)
                    } else {
                        try await Courier.shared.readMessage(message.messageId)
                    }
                } catch {
                    print("Error updating message read status: \(error)")
                }
            }
        }
        
        // Add the second action
        let action2 = UIAlertAction(title: "Archive Message", style: .default) { _ in
            Task {
                do {
                    try await Courier.shared.archiveMessage(message.messageId)
                } catch {
                    print("Error archiving message: \(error)")
                }
            }
        }
        
        let action3 = UIAlertAction(title: "View Message Details", style: .default) { _ in
            self.showCodeAlert(title: "Inbox Message", code: json ?? "")
        }
        
        // Add the cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to the action sheet
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        actionSheet.addAction(cancelAction)
        
        // Present the action sheet safely
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.present(actionSheet, animated: true)
        }
    }
    
    func showCodeAlert(title: String, code: String) {
        alert?.dismiss(animated: true)
        
        if let window = UIApplication.shared.currentWindow {
            alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            
            // Create a scrollable text view for the code
            let messageTextView = UITextView()
            messageTextView.backgroundColor = .clear
            messageTextView.text = code
            messageTextView.isEditable = false
            messageTextView.isScrollEnabled = true
            messageTextView.translatesAutoresizingMaskIntoConstraints = false
            
            // Set monospaced font for the text view
            messageTextView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular) // Adjust font size as needed
            
            // Set text view height (adjust as needed)
            let textViewHeight: CGFloat = 300
            
            // Add the text view to the alert
            alert!.view.addSubview(messageTextView)
            
            // Define constraints for the text view
            NSLayoutConstraint.activate([
                messageTextView.topAnchor.constraint(equalTo: alert!.view.topAnchor, constant: 60), // Adjust constant as needed
                messageTextView.bottomAnchor.constraint(equalTo: alert!.view.bottomAnchor, constant: -45), // Adjust constant as needed
                messageTextView.leadingAnchor.constraint(equalTo: alert!.view.leadingAnchor, constant: 8),
                messageTextView.trailingAnchor.constraint(equalTo: alert!.view.trailingAnchor, constant: -8),
                messageTextView.heightAnchor.constraint(equalToConstant: textViewHeight)
            ])
            
            // Add the "OK" button
            alert!.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            // Present the alert
            window.rootViewController?.present(alert!, animated: true, completion: nil)
        }
    }
    
    func showInputAlert(title: String, inputs: [String], action: String, onComplete: @escaping ([String]) -> Void) {
        
        alert?.dismiss(animated: true)
        
        alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )
        
        if let alert = alert {
            
            present(alert, animated: true)
            
            inputs.forEach { input in
                alert.addTextField { field in
                    field.placeholder = input
                    field.keyboardType = .default
                    field.autocorrectionType = .no
                    field.autocapitalizationType = .none
                    field.returnKeyType = .continue
                }
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
                    let values = alert.textFields?.compactMap { $0.text } ?? []
                    onComplete(values)
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
    
    @CourierActor func toJson() -> String? {
        
        let dictionary: [String: Any] = [
            "messageId": self.messageId,
            "title": self.title ?? "",
            "body": self.body ?? "",
            "preview": self.preview ?? "",
            "created": self.created ?? "",
            "read": self.isRead,
            "opened": self.isOpened,
            "archived": self.isArchived,
            "data": self.data ?? [:],
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

extension CourierUserPreferencesTopic {
    
    @objc func toJson() -> String? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted]
        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error converting to JSON: \(error.localizedDescription)")
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

class ExampleServer {
    
    private struct Response: Codable {
        let token: String
    }
    
    internal func generateJwt(authKey: String, userId: String) async throws -> String {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            
            let url = URL(string: "https://api.courier.com/auth/issue-token")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
            
            request.httpBody = try? JSONEncoder().encode([
                "scope": "user_id:\(userId) write:user-tokens inbox:read:messages inbox:write:events read:preferences write:preferences read:brands",
                "expires_in": "2 days"
            ])
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    let res = try JSONDecoder().decode(Response.self, from: data ?? Data())
                    continuation.resume(returning: res.token)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            task.resume()
            
        })
        
    }
    
}
