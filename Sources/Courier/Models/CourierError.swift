//
//  CourierError.swift
//  
//
//  Created by Michael Miller on 7/21/22.
//

import Foundation

public enum CourierError: Error {
    case noAccessTokenFound
    case noUserIdFound
    case requestError
    case sendTestMessageFail
    case inboxWebSocketError
    case inboxWebSocketFail
    case inboxWebSocketDisconnect
    case inboxUserNotFound
    case inboxUnknownError
}
