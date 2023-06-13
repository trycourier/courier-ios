//
//  CourierError.swift
//  
//
//  Created by https://github.com/mikemilla on 7/21/22.
//

import Foundation

// MARK: Public Classes

public enum CourierError: Error {
    case noAccessTokenFound
    case noUserIdFound
    case requestError
    case requestParsingError
    case sendTestMessageFail
    case inboxWebSocketError
    case inboxWebSocketFail
    case inboxWebSocketDisconnect
    case inboxUserNotFound
    case inboxUnknownError
    case inboxNotInitialized
    case inboxMessageNotFound
}

// MARK: Extensions

extension CourierError {
    
    internal var friendlyMessage: String {
        get {
            switch (self) {
            case .noAccessTokenFound:
                return "No user found"
            case .noUserIdFound:
                return "No user found"
            case .requestError:
                return "An error occurred. Please try again."
            case .requestParsingError:
                return "An error occurred data from server. Please try again."
            case .sendTestMessageFail:
                return "An error occurred sending a test message."
            case .inboxWebSocketError:
                return "An error occurred. Please try again."
            case .inboxWebSocketFail:
                return "An error occurred. Please try again."
            case .inboxWebSocketDisconnect:
                return "An error occurred. Please try again."
            case .inboxUserNotFound:
                return "No user found"
            case .inboxUnknownError:
                return "Unknown Courier Inbox error occurred. Please try again."
            case .inboxNotInitialized:
                return "The Courier Inbox is not setup. Please add a CourierInbox view or call Courier.shared.addInboxListener"
            case .inboxMessageNotFound:
                return "Courier Inbox message not found"
            }
        }
    }
    
}

extension Error {
    
    internal var friendlyMessage: String {
        get {
            guard let courierError = self as? CourierError else {
                return String(describing: self)
            }
            return courierError.friendlyMessage
        }
    }
    
}
