//
//  CourierInboxResponse.swift
//  
//
//  Created by Michael Miller on 2/23/23.
//

import Foundation

internal struct InboxResponse: Codable {
    let data: InboxData
}

internal struct InboxData: Codable {
    var count: Int? = 0
    var messages: InboxNodes?
}

extension InboxData {
    
    mutating func incrementCount() {
        
        if (count == nil) {
            count = 0
        }
        
        count! += 1
        
    }
    
}

internal struct InboxNodes: Codable {
    let pageInfo: InboxPageInfo?
    let nodes: [InboxMessage]?
}

internal struct InboxPageInfo: Codable {
    let startCursor: String?
    let hasNextPage: Bool?
}
