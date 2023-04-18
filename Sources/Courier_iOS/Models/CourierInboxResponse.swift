//
//  CourierInboxResponse.swift
//  
//
//  Created by https://github.com/mikemilla on 2/23/23.
//

import Foundation

// MARK: Internal Classes

internal struct InboxResponse: Codable {
    let data: InboxData
}

internal struct InboxData: Codable {
    var count: Int? = 0
    var messages: InboxNodes?
}

internal struct InboxNodes: Codable {
    let pageInfo: InboxPageInfo?
//    let nodes: [InboxMessage]? TODO
}

internal struct InboxPageInfo: Codable {
    let startCursor: String?
    let hasNextPage: Bool?
}

// MARK: Extensions

extension InboxData {
    
    // Increments the count
    // This exists to allow instant loading after
    // new messages arrive on the device
    internal mutating func incrementCount() {
        
        if (count == nil) {
            count = 0
        }
        
        count! += 1
        
    }
    
}
