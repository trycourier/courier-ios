//
//  CourierError.swift
//  
//
//  Created by https://github.com/mikemilla on 7/21/22.
//

import Foundation

// MARK: Public Classes

public struct CourierError: Error {
    
    public let code: Int
    public let message: String
    let type: String?
    
    public init(from error: Error) {
        if let courierError = error as? CourierError {
            self = courierError
        } else {
            self.code = (error as NSError).code
            self.message = error.localizedDescription
            self.type = String(describing: Swift.type(of: error))
        }
    }
    
    internal init(code: Int, message: String, type: String? = nil) {
        self.code = code
        self.message = message
        self.type = type
    }
    
    internal static var parsingError: CourierError {
        return CourierError(code: 420, message: "An error occurred getting data from server", type: "parsing_error")
    }
    
    internal static var userNotFound: CourierError {
        return CourierError(code: 404, message: "No user found signed in", type: "authentication_error")
    }
    
    internal static var inboxNotInitialized: CourierError {
        return CourierError(code: 403, message: "Courier Inbox is not initialized", type: "initialization_error")
    }
    
}
