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
