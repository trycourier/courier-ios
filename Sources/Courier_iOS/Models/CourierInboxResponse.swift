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

internal extension InboxResponse {
    
    func toInboxMessageSet() -> InboxMessageSet {
        return InboxMessageSet(
            messages: data?.messages?.nodes ?? [],
            totalCount: data?.count ?? 0,
            canPaginate: data?.messages?.pageInfo?.hasNextPage ?? false,
            paginationCursor: data?.messages?.pageInfo?.startCursor
        )
    }
    
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
