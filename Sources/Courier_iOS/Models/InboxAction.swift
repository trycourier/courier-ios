//
//  InboxAction.swift
//  
//
//  Created by https://github.com/mikemilla on 3/16/23.
//

import Foundation

public struct InboxAction: Codable {
    
    public let content: String?
    public let href: String?
    public private(set) var data: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case content
        case href
        case data
    }
    
    public init(content: String?, href: String?, data: [String: Any]?) {
        self.content = content
        self.href = href
        self.data = data
    }
    
    // Custom encoding for CodableValue
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(href, forKey: .href)
        
        // Encode the data dictionary
        if let dataDict = data {
            let encodableDict = dataDict.mapValues { AnyCodable($0) }
            try container.encode(encodableDict, forKey: .data)
        } else {
            try container.encodeNil(forKey: .data)
        }
    }
    
    // Custom decoding for CodableValue
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.href = try container.decodeIfPresent(String.self, forKey: .href)
        
        // Decode the data dictionary
        if let dataDict = try? container.decodeIfPresent([String: AnyCodable].self, forKey: .data) {
            self.data = dataDict.compactMapValues { $0.value }
        } else {
            self.data = nil
        }
    }
    
}

/**
 * Extensions
 */

extension InboxAction {
    
    /// The id Courier uses to attribute a click to this action.
    ///
    /// It travels on the action rather than on the message, so a click is recorded against the
    /// button the user actually pressed. A template that opts out of tracking arrives without
    /// one.
    public var trackingId: String? {
        return data?["trackingId"] as? String
    }
    
    /// Report a click on this action.
    ///
    /// `CourierInbox` does this for you when an action is pressed. Call it yourself when you
    /// render your own action buttons. A no-op when the action carries no tracking id.
    @CourierActor
    public func markAsClicked(messageId: String) async throws {
        guard let trackingId = trackingId else {
            return
        }
        try await Courier.shared.client?.inbox.click(messageId: messageId, trackingId: trackingId)
    }
    
    public func markAsClicked(messageId: String, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await markAsClicked(messageId: messageId)
                await MainActor.run {
                    onSuccess?()
                }
            } catch {
                let e = CourierError(from: error)
                await Courier.shared.client?.log(e.message)
                await MainActor.run {
                    onFailure?(e)
                }
            }
        }
    }
    
}
