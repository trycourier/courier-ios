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

@objc public class InboxMessage: NSObject, Codable {
    
    public let title: String?
    public let body: String?
    public let preview: String?
    public let created: String?
//    let actions: String?
    internal var archived: Bool?
    internal var read: String?
    public let messageId: String
    public let tags: [String]?
    
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
    
    @objc public var isRead: Bool {
        get {
            return read != nil
        }
    }
    
    @objc public var isArchived: Bool {
        get {
            return archived != nil
        }
    }
    
}

extension InboxMessage {
    
    @objc public func markAsRead() async throws {
        try await Courier.shared.inbox.readMessage(messageId: messageId)
    }
    
    @objc public func markAsRead(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await Courier.shared.inbox.readMessage(messageId: messageId)
                onSuccess()
            } catch {
                Courier.log(String(describing: error))
                onFailure(error)
            }
        }
    }
    
    @objc public func markAsUnread() async throws {
        try await Courier.shared.inbox.unreadMessage(messageId: messageId)
    }
    
    @objc public func markAsUnread(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        Task {
            do {
                try await Courier.shared.inbox.unreadMessage(messageId: messageId)
                onSuccess()
            } catch {
                Courier.log(String(describing: error))
                onFailure(error)
            }
        }
    }
    
}
