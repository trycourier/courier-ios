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
    let nodes: [InboxMessage]
}

@objc public class InboxMessage: NSObject, Codable {
    
    let title: String?
    let body: String?
    let preview: String?
    let created: String?
//    let actions: String?
    let archived: Bool?
    let read: Bool?
    let messageId: String
    let tags: String?
    
    public init(title: String?, body: String?, preview: String?, created: String?, archived: Bool?, read: Bool?, messageId: String, tags: String?) {
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
