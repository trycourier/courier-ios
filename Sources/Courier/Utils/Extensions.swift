//
//  File.swift
//  
//
//  Created by Michael Miller on 7/8/22.
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
