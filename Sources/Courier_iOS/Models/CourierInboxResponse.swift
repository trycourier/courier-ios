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
        if (count == nil) {
            count = 0
        }
        count! += 1
    }
    
}


public struct InboxNodes: Codable {
    
    let pageInfo: InboxPageInfo?
    let nodes: [InboxMessage]?
    
//    init(_ dictionary: [String : Any]?) {
//        
//        self.pageInfo = InboxPageInfo(dictionary?["pageInfo"] as? [String : Any])
//        
//        let allNodes = dictionary?["nodes"] as? [[String: Any]]
//        self.nodes = allNodes?.map { messageDictionary in
//            return InboxMessage(messageDictionary)
//        }
//
//    }
    
}

public struct InboxPageInfo: Codable {
    
    let startCursor: String?
    let hasNextPage: Bool?
    
//    init(_ dictionary: [String : Any]?) {
//        self.startCursor = dictionary?["startCursor"] as? String
//        self.hasNextPage = dictionary?["hasNextPage"] as? Bool
//    }
    
}
