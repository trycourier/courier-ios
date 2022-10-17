//
//  File.swift
//  
//
//  Created by Michael Miller on 7/8/22.
//

import Foundation
import UserNotifications

internal var isDebuggerAttached: Bool {
    return getppid() != 1
}

extension Data {
    
    // Converts the object to a string
    var string: String {
       return map { String(format: "%02.2hhx", $0) }.joined()
    }
    
}

extension UNNotificationContent {
    
    public var pushNotification: [AnyHashable : Any?] {
        get {
            
            // Initial payload
            var payload: [AnyHashable : Any?] = [
                "title": title,
                "subtitle": nil,
                "body": body,
                "badge": badge,
                "sound": nil
            ]
            
            // Do not add subtitle if it's empty
            if (!subtitle.isEmpty) {
                payload["subtitle"] = subtitle
            }
            
            // Add sound as a string
            if let aps = userInfo["aps"] as? [AnyHashable : Any?], let sound = aps["sound"] {
                payload["sound"] = sound
            }
            
            // Merge the payload data
            // This appends all custom attributes
            var data = userInfo
            data.removeValue(forKey: "aps")
            data.forEach { payload[$0] = $1 }
            
            // Add the raw data
            payload["raw"] = userInfo
            
            return payload
            
        }
    }
    
}
