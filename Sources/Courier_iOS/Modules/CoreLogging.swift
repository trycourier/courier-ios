//
//  CoreLogging.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import Foundation

internal class CoreLogging {
    
    internal var isDebugging = false
    
    internal var logListener: ((String) -> Void)? = nil
    
    internal func log(_ data: String) {
        
        // Print the log if we are debugging
        if (isDebugging) {
            print(data)
            logListener?(data)
        }
        
    }
    
}

extension Courier {
    
    /**
     * Determines if the SDK should show logs or other debugging data
     * Set to find debug mode by default
     */
    @objc public var isDebugging: Bool {
        get {
            return logging.isDebugging
        }
        set {
            logging.isDebugging = newValue
        }
    }
    
    // Called when logs are performed
    // Used for React Native and Flutter SDKs
    @objc public var logListener: ((String) -> Void)? {
        get {
            return logging.logListener
        }
        set {
            logging.logListener = newValue
        }
    }
    
    @objc public static func log(_ data: String) {
        Courier.shared.logging.log(data)
    }
    
}
