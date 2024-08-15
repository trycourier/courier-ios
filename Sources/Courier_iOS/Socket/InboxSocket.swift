//
//  InboxSocket.swift
//
//
//  Created by https://github.com/mikemilla on 7/23/24.
//

import Foundation

public class InboxSocket: CourierSocket {
    
    private let options: CourierClient.Options
    
    enum PayloadType: String, Codable {
        case event = "event"
        case message = "message"
    }
    
    enum EventType: String, Codable {
        case read = "read"
        case unread = "unread"
        case markAllRead = "mark-all-read"
        case opened = "opened"
        case archive = "archive"
    }
    
    struct SocketPayload: Codable {
        let type: PayloadType
        let event: EventType?
    }
    
    public struct MessageEvent: Codable {
        let event: EventType
        let messageId: String?
        let type: String
    }
    
    public var receivedMessage: ((InboxMessage) -> Void)?
    public var receivedMessageEvent: ((MessageEvent) -> Void)?
    
    init(options: CourierClient.Options) {
        self.options = options
        
        let url = InboxSocket.buildUrl(clientKey: options.clientKey, jwt: options.jwt)
        super.init(url: url)
        
        // Handle received messages
        self.onMessageReceived = { [weak self] data in
            self?.convertToType(from: data)
        }
        
    }
    
    private func convertToType(from data: String) {
        
        do {
            
            let decoder = JSONDecoder()
            let json = data.data(using: .utf8) ?? Data()
            let payload = try decoder.decode(SocketPayload.self, from: json)
            
            switch (payload.type) {
            case .event:
                
                let messageEvent = try decoder.decode(MessageEvent.self, from: json)
                receivedMessageEvent?(messageEvent)
                
            case .message:
                
                let dictionary = try json.toDictionary()
                let message = InboxMessage(dictionary)
                receivedMessage?(message)
                
            }
            
        } catch {
            self.onError?(error)
        }
        
    }
    
    public func sendSubscribe(version: Int = 5) async throws {
        
        var data: [String: Any] = [
            "action": "subscribe",
            "data": [
                "channel": options.userId,
                "event": "*",
                "version": version
            ]
        ]
        
        if var dict = data["data"] as? [String: Any] {
            
            if let clientKey = self.options.clientKey {
                dict["clientKey"] = clientKey
            }
            
            if let connectionId = self.options.connectionId {
                dict["clientSourceId"] = connectionId
            }
            
            if let tenantId = self.options.tenantId {
                dict["accountId"] = tenantId
            }
            
            data["data"] = dict
            
        }
        
        try await send(data)
        
    }
    
    private static func buildUrl(clientKey: String?, jwt: String?) -> String {
        var url = CourierApiClient.INBOX_WEBSOCKET
        if let jwt = jwt {
            url += "/?auth=\(jwt)"
        } else if let clientKey = clientKey {
            url += "/?clientKey=\(clientKey)"
        }
        return url
    }
    
}
