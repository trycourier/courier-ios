//
//  InboxSocket.swift
//
//
//  Created by Michael Miller on 6/10/24.
//

import Foundation

public class InboxSocket: CourierSocket {
    
    internal enum PayloadType: String, Codable {
        case event
        case message
    }
    
    internal enum EventType: String, Codable {
        case read = "read"
        case unread = "unread"
        case markAllRead = "mark-all-read"
        case opened = "opened"
    }
    
    internal struct SocketPayload: Codable {
        let type: PayloadType
        let event: EventType?
    }
    
    internal struct MessageEvent: Codable {
        let event: EventType
        let messageId: String?
        let type: String
    }
    
    private let clientKey: String?
    private let jwt: String?
    
    init(clientKey: String?, jwt: String?, onClose: @escaping (URLSessionWebSocketTask.CloseCode, Data?) -> Void, onError: @escaping (any Error) -> Void) {
        
        self.clientKey = clientKey
        self.jwt = jwt
        
        // Create the url
        var url = Repository.CourierUrl.inboxWebSocket
        if let jwt = self.jwt {
            url += "/?auth=\(jwt)"
        } else if let clientKey = self.clientKey {
            url += "/?clientKey=\(clientKey)"
        }
        
        super.init(
            url: url,
            onClose: onClose,
            onError: onError
        )
        
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
    
    func sendSubscribe(userId: String, tenantId: String?, clientSourceId: String, version: Int = 5) async throws {
        
        var data: [String: Any] = [
            "action": "subscribe",
            "data": [
                "channel": userId,
                "event": "*",
                "version": version,
                "clientSourceId": clientSourceId
            ]
        ]
        
        if var dict = data["data"] as? [String: Any] {
            
            if let clientKey = self.clientKey {
                dict["clientKey"] = clientKey
            }
            
            if let tenantId = tenantId {
                dict["accountId"] = tenantId
            }
            
            data["data"] = dict
            
        }
        
        return try await self.send(data)
        
    }
    
    var receivedMessage: ((InboxMessage) -> Void)?
    
    var receivedMessageEvent: ((MessageEvent) -> Void)?
    
}
