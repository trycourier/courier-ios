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
    
    // Push handlers have no screen of their own, so they present over whatever is showing
    var topViewController: UIViewController? {
        var top = currentWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
    
}

extension AppDelegate {
    
    func showCode(title: String, code: String) {
        UIApplication.shared.topViewController?.showCode(title: title, code: code)
    }
    
}

extension UIViewController {
    
    func showActionSheet(message: InboxMessage) {
        
        let actionSheet = UIAlertController(title: message.title, message: message.messageId, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: message.isRead ? "Mark as Unread" : "Mark as Read", style: .default) { _ in
            Task {
                message.isRead ? try? await Courier.shared.unreadMessage(message.messageId) : try? await Courier.shared.readMessage(message.messageId)
            }
        })
        
        actionSheet.addAction(UIAlertAction(title: "Archive", style: .destructive) { _ in
            Task {
                try? await Courier.shared.archiveMessage(message.messageId)
            }
        })
        
        actionSheet.addAction(UIAlertAction(title: "View Details", style: .default) { _ in
            self.showCode(title: "Inbox Message", code: message.toJson() ?? "")
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad shows action sheets as popovers, which need an anchor
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        UIApplication.shared.topViewController?.present(actionSheet, animated: true)
        
    }
    
    func showCode(title: String, code: String) {
        let navigationController = UINavigationController(rootViewController: CodeViewController(title: title, code: code))
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(navigationController, animated: true)
    }
    
    func showToast(_ text: String, systemImage: String = "checkmark.circle.fill") {
        
        guard let window = view.window else { return }
        
        // Liquid Glass on iOS 26, the closest material before it
        let effect: UIVisualEffect
        if #available(iOS 26.0, *) {
            effect = UIGlassEffect()
        } else {
            effect = UIBlurEffect(style: .systemThickMaterial)
        }
        
        // Starts with no effect, because glass only appears when its effect is animated in, not its alpha
        let toast = UIVisualEffectView(effect: nil)
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.layer.cornerRadius = 22
        toast.layer.cornerCurve = .continuous
        toast.clipsToBounds = true
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = text
        configuration.image = UIImage(systemName: systemImage)
        configuration.imagePadding = 8
        configuration.baseForegroundColor = .label
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 18, bottom: 12, trailing: 18)
        
        let label = UIButton(configuration: configuration)
        label.isUserInteractionEnabled = false
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        toast.contentView.addSubview(label)
        window.addSubview(toast)
        
        // Sit above the tab bar
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: toast.contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: toast.contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: toast.contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: toast.contentView.trailingAnchor),
            toast.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -72)
        ])
        
        UIAccessibility.post(notification: .announcement, argument: text)
        
        UIView.animate(withDuration: 0.25) {
            toast.effect = effect
            label.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.4) {
                toast.effect = nil
                label.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview()
            }
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
    
    internal func generateJwt(baseUrl: String, authKey: String, userId: String) async throws -> String {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            
            let url = URL(string: "\(baseUrl)/auth/issue-token")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
            
            request.httpBody = try? JSONEncoder().encode([
                "scope": "user_id:\(userId) write:user-tokens inbox:read:messages inbox:write:events read:preferences write:preferences read:brands",
                "expires_in": "2 days"
            ])
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    // Log raw data as String
                    if let rawString = String(data: data, encoding: .utf8) {
                        print("Raw Response: \(rawString)")
                    }
                    
                    // Log response headers
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Status Code: \(httpResponse.statusCode)")
                        print("Headers: \(httpResponse.allHeaderFields)")
                    }
                }
                
                if let error = error {
                    print("Network Error: \(error)")
                }
                
                do {
                    let res = try JSONDecoder().decode(Response.self, from: data ?? Data())
                    continuation.resume(returning: res.token)
                } catch {
                    print("Decode Error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
            
            task.resume()
            
        })
        
    }
    
}
