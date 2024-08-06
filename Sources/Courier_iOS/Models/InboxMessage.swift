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
public struct InboxMessage: Codable {
    
    // MARK: Properties
    
    public let messageId: String
    public let title: String?
    public let body: String?
    public let preview: String?
    public let created: String?
    public let actions: [InboxAction]?
    public let data: [String: Any]?
    public let trackingIds: CourierTrackingIds?
    
    public var archived: Bool?
    public var read: String?
    public var opened: String?
    
    enum CodingKeys: String, CodingKey {
        case messageId
        case title
        case body
        case preview
        case created
        case actions
        case data
        case trackingIds
        case archived
        case read
        case opened
    }
    
    // MARK: Init
    
    public init(
        messageId: String,
        title: String? = nil,
        body: String? = nil,
        preview: String? = nil,
        created: String? = nil,
        actions: [InboxAction]? = nil,
        data: [String: Any]? = nil,
        trackingIds: CourierTrackingIds? = nil,
        archived: Bool? = nil,
        read: String? = nil,
        opened: String? = nil
    ) {
        self.messageId = messageId
        self.title = title
        self.body = body
        self.preview = preview
        self.created = created
        self.actions = actions
        self.data = data
        self.trackingIds = trackingIds
        self.archived = archived
        self.read = read
        self.opened = opened
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try values.decode(String.self, forKey: .messageId)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        body = try values.decodeIfPresent(String.self, forKey: .body)
        preview = try values.decodeIfPresent(String.self, forKey: .preview)
        created = try values.decodeIfPresent(String.self, forKey: .created)
        actions = try values.decodeIfPresent([InboxAction].self, forKey: .actions)
        
        // Decode `data` as Data and then convert it to [String: Any]
        let data = try values.decodeIfPresent(Data.self, forKey: .data)
        if let data = data {
            self.data = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } else {
            self.data = nil
        }
        
        trackingIds = try values.decodeIfPresent(CourierTrackingIds.self, forKey: .trackingIds)
        archived = try values.decodeIfPresent(Bool.self, forKey: .archived)
        read = try values.decodeIfPresent(String.self, forKey: .read)
        opened = try values.decodeIfPresent(String.self, forKey: .opened)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(preview, forKey: .preview)
        try container.encodeIfPresent(created, forKey: .created)
        try container.encodeIfPresent(actions, forKey: .actions)
        
        // Convert `data` to Data and encode
        if let data = data {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            try container.encode(jsonData, forKey: .data)
        } else {
            try container.encodeNil(forKey: .data)
        }
        
        try container.encodeIfPresent(trackingIds, forKey: .trackingIds)
        try container.encodeIfPresent(archived, forKey: .archived)
        try container.encodeIfPresent(read, forKey: .read)
        try container.encodeIfPresent(opened, forKey: .opened)
        
    }
    
    // MARK: Methods
    
    public func copy() throws -> InboxMessage {
        let message = try JSONEncoder().encode(self)
        return try JSONDecoder().decode(InboxMessage.self, from: message)
    }
    
    public var subtitle: String? {
        return body ?? preview
    }
    
    public var isRead: Bool {
        return read != nil
    }
    
    public var isOpened: Bool {
        return opened != nil
    }
    
    public var isArchived: Bool {
        return archived != nil
    }
    
    public func setRead() throws -> InboxMessage {
        var message = try copy()
        message.read = Date().timestamp
        return message
    }
    
    public func setUnread() throws -> InboxMessage {
        var message = try copy()
        message.read = Date().timestamp
        return message
    }
    
    public mutating func setOpened() {
        opened = Date().timestamp
    }
    
    public var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        guard let createdAt = created, let date = dateFormatter.date(from: createdAt) else {
            return "now"
        }
        
        return date.timeSince()
    }
    
}

public extension InboxMessage {
    
    func markAsRead() async throws {
        try await Courier.shared.readMessage(messageId)
    }
    
    func markAsRead(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await markAsRead()
                onSuccess?()
            } catch {
                let e = CourierError(from: error)
                Courier.shared.client?.log(e.message)
                onFailure?(e)
            }
        }
    }
    
    func markAsUnread() async throws {
        try await Courier.shared.unreadMessage(messageId)
    }
    
    func markAsUnread(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await markAsUnread()
                onSuccess?()
            } catch {
                let e = CourierError(from: error)
                Courier.shared.client?.log(e.message)
                onFailure?(e)
            }
        }
    }
    
    func markAsOpened() async throws {
        try await Courier.shared.openMessage(messageId)
    }
    
    func markAsOpened(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await markAsOpened()
                onSuccess?()
            } catch {
                let e = CourierError(from: error)
                Courier.shared.client?.log(e.message)
                onFailure?(e)
            }
        }
    }
    
    func markAsClicked() async throws {
        try await Courier.shared.clickMessage(messageId)
    }
    
    func markAsClicked(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await markAsClicked()
                onSuccess?()
            } catch {
                let e = CourierError(from: error)
                Courier.shared.client?.log(e.message)
                onFailure?(e)
            }
        }
    }
    
    func markAsArchived() async throws {
        try await Courier.shared.archiveMessage(messageId)
    }
    
    func markAsArchived(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await markAsArchived()
                onSuccess?()
            } catch {
                let e = CourierError(from: error)
                Courier.shared.client?.log(e.message)
                onFailure?(e)
            }
        }
    }
    
}
