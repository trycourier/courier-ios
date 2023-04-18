//
//  InboxMessage.swift
//  
//
//  Created by https://github.com/mikemilla on 3/10/23.
//

import Foundation

/**
 The model used to structure CourierInbox messages
 */
@objc public class InboxMessage: NSObject {
    
    // MARK: Properties
    
    @objc public let messageId: String
    @objc public let title: String?
    @objc public let body: String?
    @objc public let preview: String?
    @objc public let created: String?
    @objc public let actions: [InboxAction]?
    
    internal var archived: Bool?
    internal var read: String?
    internal var opened: String?
    
    internal init(_ dictionary: [String : Any]?) {
        
        let actions = dictionary?["actions"] as? [[String: Any]]

        let buttons = actions?.map { action in
            return InboxAction(
                content: action["content"] as? String,
                href: action["href"] as? String,
                data: action["data"] as? [String : Any]
            )
        }
        
        self.title = dictionary?["title"] as? String
        self.body = dictionary?["body"] as? String
        self.preview = dictionary?["preview"] as? String
        self.created = dictionary?["created"] as? String
        self.archived = dictionary?["archived"] as? Bool
        self.read = dictionary?["read"] as? String
        self.messageId = dictionary?["messageId"] as! String
        self.actions = buttons
        
    }
    
    @objc public var subtitle: String? {
        get {
            return body ?? preview
        }
    }
    
    @objc public var isRead: Bool {
        get {
            return read != nil
        }
    }
    
    @objc public var isOpened: Bool {
        get {
            return opened != nil
        }
    }
    
    @objc public var isArchived: Bool {
        get {
            return archived != nil
        }
    }
    
    internal func setRead() {
        read = Date().timestamp
    }
    
    internal func setOpened() {
        opened = Date().timestamp
    }
    
    @objc public var time: String {
        get {
         
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            
            guard let createdAt = created, let date = dateFormatter.date(from: createdAt) else {
                return "now"
            }
            
            return date.timeSince()
            
        }
    }
    
}

extension InboxMessage {
    
    @objc public func markAsRead() async throws {
        try await Courier.shared.inbox.readMessage(messageId: messageId)
    }
    
    @objc public func markAsRead(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await Courier.shared.inbox.readMessage(messageId: messageId)
                onSuccess?()
            } catch {
                Courier.log(error.friendlyMessage)
                onFailure?(error)
            }
        }
    }
    
    @objc public func markAsUnread() async throws {
        try await Courier.shared.inbox.unreadMessage(messageId: messageId)
    }
    
    @objc public func markAsUnread(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await Courier.shared.inbox.unreadMessage(messageId: messageId)
                onSuccess?()
            } catch {
                Courier.log(error.friendlyMessage)
                onFailure?(error)
            }
        }
    }
    
}
