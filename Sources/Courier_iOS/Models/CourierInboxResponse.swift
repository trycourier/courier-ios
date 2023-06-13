//
//  CourierInboxResponse.swift
//  
//
//  Created by https://github.com/mikemilla on 2/23/23.
//

import Foundation

// MARK: Internal Classes

@objc internal class InboxResponse: NSObject {
    
    let data: InboxData?
    
    init(_ dictionary: [String : Any]?) {
        let data = dictionary?["data"] as? [String: Any]
        self.data = InboxData(data)
    }
    
}

@objc internal class InboxData: NSObject {
    
    var count: Int? = 0
    var messages: InboxNodes?
    
    init(_ dictionary: [String : Any]?) {
        self.count = dictionary?["count"] as? Int
        self.messages = InboxNodes(dictionary?["messages"] as? [String : Any])
    }
    
    func incrementCount() {
        if (count == nil) {
            count = 0
        }
        count! += 1
    }
    
}


@objc internal class InboxNodes: NSObject {
    
    let pageInfo: InboxPageInfo?
    let nodes: [InboxMessage]?
    
    init(_ dictionary: [String : Any]?) {
        
        self.pageInfo = InboxPageInfo(dictionary?["pageInfo"] as? [String : Any])
        
        let allNodes = dictionary?["nodes"] as? [[String: Any]]
        self.nodes = allNodes?.map { messageDictionary in
            return InboxMessage(messageDictionary)
        }

    }
    
}

@objc internal class InboxPageInfo: NSObject {
    
    let startCursor: String?
    let hasNextPage: Bool?
    
    init(_ dictionary: [String : Any]?) {
        self.startCursor = dictionary?["startCursor"] as? String
        self.hasNextPage = dictionary?["hasNextPage"] as? Bool
    }
    
}
