//
//  CourierWebSocket.swift
//  
//
//  Created by https://github.com/mikemilla on 2/21/24.
//

import Foundation

internal class CourierInboxWebsocket {
    
    private static var instance: CourierWebsocket?
    static var onMessageReceived: ((String) -> Void)?
    
    static var shared: CourierWebsocket? {
        
        if (Courier.shared.clientKey == nil && Courier.shared.jwt == nil) {
            disconnect()
            return instance
        }
        
        var url = Repository.CourierUrl.inboxWebSocket
        if let jwt = Courier.shared.jwt {
            url += "/?auth=\(jwt)"
        } else if let clientKey = Courier.shared.clientKey {
            url += "/?clientKey=\(clientKey)"
        }
        
        if instance?.url.absoluteString != url {
            instance = CourierWebsocket(url: URL(string: url)!) { text in
                onMessageReceived?(text)
            }
        }
        
        return instance
        
    }
    
    static func connect(clientKey: String?, tenantId: String?, userId: String) {
        
        var jsonData: [String: Any] = [
            "action": "subscribe",
            "data": [
                "channel": userId,
                "event": "*",
                "version": "4"
            ]
        ]
        
        if let clientKey = clientKey {
            if var data = jsonData["data"] as? [String: Any] {
                data["clientKey"] = clientKey
                jsonData["data"] = data
            }
        }
        
        if let tenantId = tenantId {
            if var data = jsonData["data"] as? [String: Any] {
                data["accountId"] = tenantId
                jsonData["data"] = data
            }

        }
        
        do {
            let json = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
            if let jsonString = String(data: json, encoding: .utf8) {
                shared?.connect(json: jsonString)
            } else {
                Courier.log("Error converting data to string")
            }
        } catch {
            Courier.log(error.localizedDescription)
        }
        
    }
    
    static func disconnect() {
        onMessageReceived = nil
        instance?.disconnect()
        instance = nil
    }
    
}

internal class CourierWebsocket {
    
    internal let url: URL
    private var webSocketTask: URLSessionWebSocketTask!
    private var state: ConnectionState = .closed
    
    var isSocketConnected: Bool {
        return state == .opened
    }
    
    var isSocketConnecting: Bool {
        return state == .connecting
    }
    
    init(url: URL, onMessageReceived: @escaping (String) -> Void) {
        self.url = url
        self.webSocketTask = URLSession.shared.webSocketTask(with: url)
        self.setupWebSocket(with: onMessageReceived)
    }
    
    private func setupWebSocket(with onMessageReceived: @escaping (String) -> Void) {
        
        webSocketTask.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    onMessageReceived(text)
                default:
                    break
                }
                self.setupWebSocket(with: onMessageReceived)
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self.state = .failure
            }
        }
        
    }
    
    func connect(json: String) {
        
        guard !isSocketConnecting && !isSocketConnected else {
            return
        }
        
        state = .connecting
        webSocketTask.resume()
        send(json: json)
        
    }
    
    func disconnect() {
        
        webSocketTask.cancel(with: .goingAway, reason: nil)
        
    }
    
    enum ConnectionState {
        case connecting
        case opened
        case closed
        case failure
    }
    
    private func send(json: String) {
        
        let message = URLSessionWebSocketTask.Message.string(json)
        
        webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
                self.state = .failure
            }
        }
        
    }
    
}
