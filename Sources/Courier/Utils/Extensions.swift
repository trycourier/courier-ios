//
//  File.swift
//  
//
//  Created by https://github.com/mikemilla on 7/8/22.
//

import UIKit

internal var isDebuggerAttached: Bool {
    return getppid() != 1
}

extension Data {
    
    // Converts the object to a string
    var string: String {
       return map { String(format: "%02.2hhx", $0) }.joined()
    }
    
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
    @available(iOSApplicationExtension, unavailable)
    @objc public static func openSettingsForApp() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }
    
}

extension Date {
    
    internal func timeSince() -> String {
        
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
    
}

extension UIColor {
  
    internal convenience init?(_ hex: String, alpha: CGFloat = 1.0) {
      
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

    internal func luminance() -> CGFloat {

        let ciColor = CIColor(color: self)

        func adjust(colorComponent: CGFloat) -> CGFloat {
            return (colorComponent < 0.04045) ? (colorComponent / 12.92) : pow((colorComponent + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * adjust(colorComponent: ciColor.red) + 0.7152 * adjust(colorComponent: ciColor.green) + 0.0722 * adjust(colorComponent: ciColor.blue)
        
    }

}

extension Date {
    
    internal var timestamp: String {
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

extension Bundle {
    
    internal static func current(for className: AnyClass) -> Bundle {
        #if SWIFT_PACKAGE
        return Bundle(for: className)
        #else
        return Bundle(for: className)
        #endif
    }
    
}
