//
//  File.swift
//
//
//  Created by https://github.com/mikemilla on 7/8/22.
//

import UIKit

extension Data {
    
    // Converts the object to a string
    public var string: String {
       return map { String(format: "%02.2hhx", $0) }.joined()
    }
    
}

internal var isDebuggerAttached: Bool {
    return getppid() != 1
}

extension Courier {
    
    @objc public static func formatPushNotification(content: UNNotificationContent) -> Dictionary<AnyHashable, Any> {
        
        // Initial payload
        var payload: Dictionary<AnyHashable, Any> = [
            "title": content.title,
            "body": content.body
        ]
        
        if let badge = content.badge {
            payload["badge"] = badge
        }
        
        // Do not add subtitle if it's empty
        if (!content.subtitle.isEmpty) {
            payload["subtitle"] = content.subtitle
        }
        
        // Add sound as a string
        if let aps = content.userInfo["aps"] as? [AnyHashable : Any?], let sound = aps["sound"] {
            payload["sound"] = sound
        }
        
        // Merge the payload data
        // This appends all custom attributes
        var data = content.userInfo
        data.removeValue(forKey: "aps")
        data.forEach { payload[$0] = $1 }
        
        // Add the raw data
        payload["raw"] = content.userInfo
        
        return payload
        
    }
    
    // Shortcut to open the settings app for the current app
    @MainActor @available(iOSApplicationExtension, unavailable)
    @objc public static func openSettingsForApp() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }
    
    @discardableResult @objc public static func requestNotificationPermission() async throws -> UNAuthorizationStatus {
        try await userNotificationCenter.requestAuthorization(options: permissionAuthorizationOptions)
        return try await Courier.getNotificationPermissionStatus()
    }
    
    @objc public static func requestNotificationPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
        userNotificationCenter.requestAuthorization(
            options: permissionAuthorizationOptions,
            completionHandler: { _, _ in
                
                // Get the full status of the permission
                getNotificationPermissionStatus { permission in
                    completion(permission)
                }
                
            }
        )
    }
    
    @objc public static func getNotificationPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        userNotificationCenter.getNotificationSettings(completionHandler: { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        })
    }
    
    @objc public static func getNotificationPermissionStatus() async throws -> UNAuthorizationStatus {
        let settings = await userNotificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
}

internal extension Date {
    
    func timeSince() -> String {
        
        var formattedString = String()
        let now = Date()
        let secondsAgo = Int(now.timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        let year = 12 * month
        
        let secondString = "s"
        let minuteString = "m"
        let hourString = "h"
        let dayString = "d"
        let weekString = "w"
        let yearString = "y"
        
        if (secondsAgo < minute) {
            formattedString = "\(secondsAgo)\(secondString)"
        } else if (secondsAgo < hour) {
            formattedString = "\(secondsAgo / minute)\(minuteString)"
        } else if (secondsAgo < day) {
            formattedString = "\(secondsAgo / hour)\(hourString)"
        } else if (secondsAgo < week) {
            formattedString = "\(secondsAgo / day)\(dayString)"
        } else if (secondsAgo < year) {
            formattedString = "\(secondsAgo / week)\(weekString)"
        } else {
            formattedString = "\(secondsAgo / year)\(yearString)"
        }
        
        return formattedString
        
    }
    
    var timestamp: String {
        get {
            if #available(iOS 15.0, *) {
                return ISO8601Format()
            } else {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions.insert(.withFractionalSeconds)
                return formatter.string(from: self)
            }
        }
    }
    
}

internal extension UIColor {
  
    convenience init?(_ hex: String, alpha: CGFloat = 1.0) {
      
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
        if cString.hasPrefix("#") {
            cString.removeFirst()
        }
    
        if cString.count != 6 {
            return nil
        }
    
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
    
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
      
    }

    func luminance() -> CGFloat {

        let ciColor = CIColor(color: self)

        func adjust(colorComponent: CGFloat) -> CGFloat {
            return (colorComponent < 0.04045) ? (colorComponent / 12.92) : pow((colorComponent + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * adjust(colorComponent: ciColor.red) + 0.7152 * adjust(colorComponent: ciColor.green) + 0.0722 * adjust(colorComponent: ciColor.blue)
        
    }

}

internal extension Bundle {
    
    static func current(for className: AnyClass) -> Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let bundle = Bundle(for: className)
        return Bundle(url: bundle.url(forResource: "Media", withExtension: "bundle")!)!
        #endif
    }
    
}

extension Dictionary {
    
    func toJson() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch {
            return nil
        }
    }
    
}

extension [String : String] {
    
    func toPreview() -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]), let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            return String(describing: self)
        }
    }
    
}

extension Data {
    
    func toPreview() -> String {
        do {
            // Attempt to deserialize JSON
            let json = try JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed)
            
            // Attempt to pretty-print JSON
            let prettyJsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            // Convert the data to a string and return
            if let prettyJsonString = String(data: prettyJsonData, encoding: .utf8) {
                return prettyJsonString
            }
            
            // Fallback to plain UTF-8 string if conversion fails
            return String(decoding: self, as: UTF8.self)
        } catch {
            // Log the error and fallback to plain UTF-8 string
            let string = String(decoding: self, as: UTF8.self)
            print("JSON Parsing Error: \(error.localizedDescription)\n\(string)")
            return string
        }
    }
    
    func toDictionary() throws -> [String : Any]? {
        return try JSONSerialization.jsonObject(with: self, options: []) as? [String : Any]
    }
    
}

extension UIView {
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            parentResponder = responder.next
        }
        return nil
    }
    
}

public extension [AnyHashable : Any] {
    
    func trackMessage(event: CourierTrackingEvent) async {
        
        guard let trackingUrl = self["trackingUrl"] as? String else {
            return
        }
        
        await trackingUrl.track(with: event)
        
    }
    
    var trackingUrl: String? {
        
        guard let trackingUrl = self["trackingUrl"] as? String else {
            return nil
        }
        
        return trackingUrl
        
    }
    
}

public extension String {
    
    func track(with event: CourierTrackingEvent) async {
        
        let client = CourierClient.default
        
        do {
            try await client.tracking.postTrackingUrl(
                url: self,
                event: event
            )
        } catch {
            client.options.error(error.localizedDescription)
        }
        
    }
    
}

public extension NSDictionary {
    
    @objc func trackMessage(event: CourierTrackingEvent, completion: @escaping (Error?) -> Void) {
        
        guard let trackingUrl = self["trackingUrl"] as? String else {
            completion(nil)
            return
        }
        
        let client = CourierClient.default
        
        Task {
         
            do {
                try await client.tracking.postTrackingUrl(
                    url: trackingUrl,
                    event: event
                )
                completion(nil)
            } catch {
                client.options.error(error.localizedDescription)
                completion(error)
            }
            
        }
        
    }
    
}

internal func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}

internal extension UIColor {
    func toHexString() -> String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        print(hexString)
        return hexString
    }
}

internal extension UIButton {
    func appendAccessibilityIdentifier(_ prefix: String) {
        if Courier.shared.isUITestsActive {
            self.accessibilityIdentifier = "\(prefix)Button, backgroundColor: \(String(describing: backgroundColor)), cornerRadius: \(layer.cornerRadius)"

            let fontName: String = titleLabel?.font.fontName ?? ""
            let fontSize = titleLabel?.font.pointSize ?? 0
            let fontColor: String = titleLabel?.textColor.toHexString() ?? ""
            titleLabel?.accessibilityIdentifier = "\(prefix)ButtonTitleLabel, fontName: \(fontName), fontSize: \(fontSize), fontColor: \(fontColor)"
        }
    }
}

internal extension UITableView {
    func appendAccessibilityIdentifier(_ prefix: String) {
        if Courier.shared.isUITestsActive {
            self.accessibilityIdentifier = "\(prefix)TableView, separatorStyle: \(separatorStyle), separatorInset: \(separatorInset), separatorColor: \(separatorColor?.toHexString() ?? ""), loadingColor: \(refreshControl?.tintColor.toHexString() ?? "")"
        }
    }
}

internal extension UITableViewCell {
    func appendAccessibilityIdentifier(_ prefix: String) {
        if Courier.shared.isUITestsActive {
            self.accessibilityIdentifier = "\(prefix)Cell, selectionStyle: \(selectionStyle)"
        }
    }
}

internal extension UILabel {
    func appendAccessibilityIdentifier(_ prefix: String) {
        if Courier.shared.isUITestsActive {
            self.accessibilityIdentifier = "\(prefix)Label, fontName: \(font.fontName), fontSize: \(font.pointSize), fontColor: \(textColor.toHexString())"
        }
    }
}

internal extension UIActivityIndicatorView {
    func appendAccessibilityIdentifier(_ prefix: String) {
        if Courier.shared.isUITestsActive {
            self.accessibilityIdentifier = "\(prefix)LoadingIndicator, color: \(color.toHexString())"
        }
    }
}

internal extension UISwitch {
    func appendAccessibilityIdentifier(_ prefix: String) {
        if Courier.shared.isUITestsActive {
            self.accessibilityIdentifier = "\(prefix)Switch, onTintColor: \(onTintColor?.toHexString() ?? "")"
        }
    }
}
