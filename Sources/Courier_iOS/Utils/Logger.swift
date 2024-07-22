//
//  Logger.swift
//
//
//  Created by Michael Miller on 7/22/24.
//

import Foundation
import os.log

class Logger {
    
    private static let log = OSLog(subsystem: "com.courier.ios", category: "CourierSDK")
    
    static func log(_ data: String) {
        os_log("%@", log: log, type: .debug, data)
    }
    
    static func warn(_ data: String) {
        os_log("%@", log: log, type: .fault, data)
    }
    
    static func error(_ data: String?) {
        let message = data ?? "Oops, an error occurred"
        os_log("%@", log: log, type: .error, message)
    }
    
}

// MARK: Extensions

extension CourierClient.Options {
    
    func log(_ data: String) {
        if showLogs {
            Logger.log(data)
        }
    }
    
    func warn(_ data: String) {
        if showLogs {
            Logger.warn(data)
        }
    }
    
    func error(_ data: String?) {
        if showLogs {
            Logger.error(data)
        }
    }
    
}

extension CourierClient {
    
    func log(_ data: String) {
        options.log(data)
    }
    
    func warn(_ data: String) {
        options.warn(data)
    }
    
    func error(_ data: String?) {
        options.error(data)
    }
    
}
