//
//  CourierInboxResponse.swift
//  
//
//  Created by https://github.com/mikemilla on 2/23/23.
//

import Foundation

// MARK: Internal Classes

public struct InboxResponse: Codable {
    public let data: InboxData?
}

public struct InboxData: Codable {
    
    public var count: Int? = 0
    public var messages: InboxNodes?
    
    public mutating func incrementCount() {
        if count == nil {
            count = 0
        }
        count! += 1
    }
    
}

public struct InboxNodes: Codable {
    public let pageInfo: InboxPageInfo?
    public let nodes: [InboxMessage]?
}

public struct InboxPageInfo: Codable {
    public let startCursor: String?
    public let hasNextPage: Bool?
}
