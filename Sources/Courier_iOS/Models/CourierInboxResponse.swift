//
//  CourierInboxResponse.swift
//  
//
//  Created by https://github.com/mikemilla on 2/23/23.
//

import Foundation

// MARK: Internal Classes

@objc public class InboxResponse: NSObject {
    
    public let data: InboxData?
    
    public init(_ dictionary: [String : Any]?) {
        let data = dictionary?["data"] as? [String: Any]
        self.data = InboxData(data)
    }
    
}

@objc public class InboxData: NSObject {
    
    public var count: Int? = 0
    public var messages: InboxNodes?
    
    public init(_ dictionary: [String : Any]?) {
        self.count = dictionary?["count"] as? Int
        self.messages = InboxNodes(dictionary?["messages"] as? [String : Any])
    }
    
    public func incrementCount() {
        if (count == nil) {
            count = 0
        }
        count! += 1
    }
    
}


@objc public class InboxNodes: NSObject {
    
    public let pageInfo: InboxPageInfo?
    public let nodes: [InboxMessage]?
    
    public init(_ dictionary: [String : Any]?) {
        
        self.pageInfo = InboxPageInfo(dictionary?["pageInfo"] as? [String : Any])
        
        let allNodes = dictionary?["nodes"] as? [[String: Any]]
        self.nodes = allNodes?.map { messageDictionary in
            return InboxMessage(messageDictionary)
        }

    }
    
}

@objc public class InboxPageInfo: NSObject {
    
    public let startCursor: String?
    public let hasNextPage: Bool?
    
    public init(_ dictionary: [String : Any]?) {
        self.startCursor = dictionary?["startCursor"] as? String
        self.hasNextPage = dictionary?["hasNextPage"] as? Bool
    }
    
}
