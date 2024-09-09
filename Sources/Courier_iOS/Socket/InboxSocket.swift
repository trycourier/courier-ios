//
//  InboxSocket.swift
//
//
//  Created by https://github.com/mikemilla on 7/23/24.
//

import Foundation

// MARK: Inbox Socket Singleton

internal class InboxSocketManager {

    private static var socketInstance: InboxSocket?

    static func getSocketInstance(options: CourierClient.Options) -> InboxSocket {
        if socketInstance == nil {
            socketInstance = InboxSocket(options: options)
        }
        return socketInstance!
    }

    static func closeSocket() {
        socketInstance?.disconnect()
        socketInstance = nil
    }
    
}

// MARK: Inbox Socket

public class InboxSocket: CourierSocket {
    
    private let options: CourierClient.Options
    
    enum PayloadType: String, Codable {
        case event = "event"
        case message = "message"
    }
    
    struct SocketPayload: Codable {
        let type: PayloadType
        let event: InboxEventType?
    }
    
    public struct MessageEvent: Codable {
        let event: InboxEventType
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
                
                let event = try decoder.decode(MessageEvent.self, from: json)
                receivedMessageEvent?(event)
                
            case .message:
                
                let message = try decoder.decode(InboxMessage.self, from: json)
                receivedMessage?(message)
                
            }
            
        } catch {
            
            options.error(error.localizedDescription)
            
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
