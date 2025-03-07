//
//  InboxSocket.swift
//
//
//  Created by https://github.com/mikemilla on 7/23/24.
//

import Foundation

// MARK: Inbox Socket Singleton

@CourierActor internal class InboxSocketManager {

    var socket: InboxSocket?

    @discardableResult func updateInstance(options: CourierClient.Options) async -> InboxSocket {
        await closeSocket()
        socket = InboxSocket(options: options)
        return socket!
    }

    func closeSocket() async {
        await socket?.disconnect()
        socket?.receivedMessage = nil
        socket?.receivedMessageEvent = nil
        socket = nil
    }
    
}

// MARK: Socket state. Prevents data races

internal actor InboxSocketState {
    
    private var receivedMessage: ((InboxMessage) -> Void)?
    private var receivedMessageEvent: ((InboxSocket.MessageEvent) -> Void)?

    func setReceivedMessage(_ handler: ((InboxMessage) -> Void)?) {
        self.receivedMessage = handler
    }

    func setReceivedMessageEvent(_ handler: ((InboxSocket.MessageEvent) -> Void)?) {
        self.receivedMessageEvent = handler
    }

    func callReceivedMessage(_ message: InboxMessage) {
        receivedMessage?(message)
    }

    func callReceivedMessageEvent(_ event: InboxSocket.MessageEvent) {
        receivedMessageEvent?(event)
    }
}


// MARK: Inbox Socket

public class InboxSocket: CourierSocket {
    
    private let options: CourierClient.Options
    private let state = InboxSocketState()
    
    enum PayloadType: String, Codable {
        case event = "event"
        case message = "message"
    }
    
    struct SocketPayload: Codable {
        let type: PayloadType
    }
    
    public struct MessageEvent: Codable {
        let event: InboxEventType
        let messageId: String?
        let type: String
    }
    
    internal var receivedMessage: ((InboxMessage) -> Void)?
    internal var receivedMessageEvent: ((MessageEvent) -> Void)?
    
    init(options: CourierClient.Options) {
        self.options = options
        
        let url = InboxSocket.buildUrl(options: options)
        super.init(url: url)
        
        // Handle received messages
        self.onMessageReceived = { [weak self] data in
            self?.convertToType(from: data)
        }
        
    }
    
    public func connect(receivedMessage: ((InboxMessage) -> Void)? = nil, receivedMessageEvent: ((MessageEvent) -> Void)? = nil) async throws {
        await state.setReceivedMessage(receivedMessage)
        await state.setReceivedMessageEvent(receivedMessageEvent)
        try await super.connect()
    }
    
    public func sendSubscribe(version: Int = 5) async throws {
        
        var data: [String: Any] = [
            "action": "subscribe",
            "data": [
                "userAgent": Courier.agent.value,
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
    
    private func convertToType(from data: String) {
        do {
            let decoder = JSONDecoder()
            let json = data.data(using: .utf8) ?? Data()
            let payload = try decoder.decode(SocketPayload.self, from: json)

            switch payload.type {
            case .event:
                let event = try decoder.decode(MessageEvent.self, from: json)
                Task { await state.callReceivedMessageEvent(event) } // Read safely via actor
            case .message:
                let message = try decoder.decode(InboxMessage.self, from: json)
                Task { await state.callReceivedMessage(message) } // Read safely via actor
            }
        } catch {
            options.error(error.localizedDescription)
            self.onError?(error)
        }
    }
    
    private static func buildUrl(options: CourierClient.Options) -> String {
        var url = options.apiUrls.inboxWebSocket
        if let jwt = options.jwt {
            url += "/?auth=\(jwt)"
        } else if let clientKey = options.clientKey {
            url += "/?clientKey=\(clientKey)"
        }
        return url
    }
    
}
