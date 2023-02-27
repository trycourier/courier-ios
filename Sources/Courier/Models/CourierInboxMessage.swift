//
//  CourierInboxMessage.swift
//  
//
//  Created by Michael Miller on 2/23/23.
//

import Foundation

internal struct InboxResponse: Codable {
    let data: InboxData
}

internal struct InboxData: Codable {
    let count: Int
    let messages: InboxNodes
}

internal struct InboxNodes: Codable {
    let totalCount: Int?
    let pageInfo: InboxPageInfo
    let nodes: [InboxMessage]
}

internal struct InboxPageInfo: Codable {
    let startCursor: String?
    let hasNextPage: Bool?
}

@objc public class InboxMessage: NSObject, Codable {
    
    let title: String?
    let body: String?
    let preview: String?
    let created: String?
//    let actions: String?
    let archived: Bool?
    let read: String?
    let messageId: String
    let tags: [String]?
    
    public init(title: String?, body: String?, preview: String?, created: String?, archived: Bool?, read: String?, messageId: String, tags: [String]?) {
        self.title = title
        self.body = body
        self.preview = preview
        self.created = created
        self.archived = archived
        self.read = read
        self.messageId = messageId
        self.tags = tags
    }
    
}
