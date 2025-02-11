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
public class InboxMessage: Codable {
    
    public let messageId: String
    public let title: String?
    public let body: String?
    public let preview: String?
    public let actions: [InboxAction]?
    public private(set) var data: [String: Any]?
    public let trackingIds: CourierTrackingIds?
    
    public let created: String?
    public var archived: String?
    public var read: String?
    public var opened: String?
    
    internal init(
        messageId: String,
        title: String? = nil,
        body: String? = nil,
        preview: String? = nil,
        created: String? = nil,
        archived: String? = nil,
        read: String? = nil,
        actions: [InboxAction]? = nil,
        data: [String: Any]? = nil,
        trackingIds: CourierTrackingIds? = nil
    ) {
        self.title = title
        self.body = body
        self.preview = preview
        self.created = created
        self.archived = archived
        self.read = read
        self.messageId = messageId
        self.actions = actions
        self.data = data
        self.trackingIds = trackingIds
    }
    
    public func copy() -> InboxMessage {
        return InboxMessage(messageId: messageId, title: title, body: body, preview: preview, created: created, archived: archived, read: read, actions: actions, data: data, trackingIds: trackingIds)
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
    
    internal func setArchived() {
        archived = Date().timestamp
    }
    
    internal func setUnarchived() {
        archived = nil
    }
    
    internal func setRead() {
        read = Date().timestamp
    }
    
    internal func setUnread() {
        read = nil
    }
    
    internal func setOpened() {
        opened = Date().timestamp
    }
    
    internal func setUnopened() {
        opened = nil
    }
    
    public var createdAt: Date {
        guard let created = created else {
            return Date()
        }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: created) {
            return date
        } else {
            return Date()
        }
    }
    
    public var timestamp: Int {
        return Int(createdAt.timeIntervalSince1970 * 1000)
    }
    
    public var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        guard let createdAt = created, let date = dateFormatter.date(from: createdAt) else {
            return "now"
        }
        
        return date.timeSince()
    }
    
    enum CodingKeys: String, CodingKey {
        case messageId
        case title
        case body
        case preview
        case actions
        case data
        case trackingIds
        case created
        case archived
        case read
        case opened
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.messageId = try container.decode(String.self, forKey: .messageId)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.preview = try container.decodeIfPresent(String.self, forKey: .preview)
        self.actions = try container.decodeIfPresent([InboxAction].self, forKey: .actions)
        self.trackingIds = try container.decodeIfPresent(CourierTrackingIds.self, forKey: .trackingIds)
        self.created = try container.decodeIfPresent(String.self, forKey: .created)
        self.archived = try container.decodeIfPresent(String.self, forKey: .archived)
        self.read = try container.decodeIfPresent(String.self, forKey: .read)
        self.opened = try container.decodeIfPresent(String.self, forKey: .opened)
        
        // Custom decoding logic for data dictionary
        if let dataDict = try? container.decodeIfPresent([String: AnyCodable].self, forKey: .data) {
            self.data = dataDict.compactMapValues { $0.value }
        } else {
            self.data = nil
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(preview, forKey: .preview)
        try container.encodeIfPresent(actions, forKey: .actions)
        try container.encodeIfPresent(trackingIds, forKey: .trackingIds)
        try container.encodeIfPresent(created, forKey: .created)
        try container.encodeIfPresent(archived, forKey: .archived)
        try container.encodeIfPresent(read, forKey: .read)
        try container.encodeIfPresent(opened, forKey: .opened)
        
        // Custom encoding logic for data dictionary
        if let dataDict = data {
            let encodableDict = dataDict.mapValues { AnyCodable($0) }
            try container.encode(encodableDict, forKey: .data)
        } else {
            try container.encodeNil(forKey: .data)
        }
        
    }
    
}

extension InboxMessage {
    
    public func markAsRead() async throws {
        try await Courier.shared.readMessage(messageId)
    }
    
    public func markAsRead(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
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
    
    public func markAsUnread() async throws {
        try await Courier.shared.unreadMessage(messageId)
    }
    
    public func markAsUnread(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
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
    
    public func markAsOpened() async throws {
        try await Courier.shared.openMessage(messageId)
    }
    
    public func markAsOpened(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
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
    
    public func markAsClicked() async throws {
        try await Courier.shared.clickMessage(messageId)
    }
    
    public func markAsClicked(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
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
    
    public func markAsArchived() async throws {
        try await Courier.shared.archiveMessage(messageId)
    }
    
    public func markAsArchived(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
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
