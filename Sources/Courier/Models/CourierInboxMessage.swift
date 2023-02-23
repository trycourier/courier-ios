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

internal struct InboxMessage: Codable {
    let title: String?
    let preview: String?
    let created: String?
//    let actions: String?
    let archived: Bool?
    let read: Bool?
    let messageId: String
    let tags: String?
}
