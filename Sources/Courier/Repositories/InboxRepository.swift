//
//  InboxRepository.swift
//  
//
//  Created by Michael Miller on 2/23/23.
//

import Foundation

internal struct WebSocketConnectionPayload: Codable {
    var query: String
}

internal class InboxRepository: Repository, URLSessionWebSocketDelegate {
    
    private(set) var webSocket: URLSessionWebSocketTask?
    private var onMessageReceived: ((InboxMessage) -> Void)?
    private var onMessageReceivedError: ((CourierError) -> Void)?
    
    internal func createWebSocket(clientKey: String, userId: String, onMessageReceived: @escaping (InboxMessage) -> Void, onMessageReceivedError: @escaping (CourierError) -> Void) async throws {
        
        // Open and connect to the server
        webSocket = try await openWebSocket(
            clientKey: clientKey,
            userId: userId
        )

        // Save callbacks
        self.onMessageReceived = onMessageReceived
        self.onMessageReceivedError = onMessageReceivedError
        
        // Start receiving messages
        self.handleMessageReceived()
        
    }
    
    internal func closeWebSocket() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        onMessageReceived = nil
    }
    
    private func handleMessageReceived() {
        webSocket?.receive { result in
            
            switch result {
            case .success(let message):
                
                switch message {
                case .string(let str):
                    do {
                        let data = str.data(using: .utf8) ?? Data()
                        let newMessage = try JSONDecoder().decode(InboxMessage.self, from: data)
                        self.onMessageReceived?(newMessage)
                    } catch {
                        Courier.log(String(describing: error))
                        self.onMessageReceivedError?(CourierError.inboxWebSocketError)
                    }
                case .data(_):
                    break
                @unknown default:
                    break
                }
                
                self.handleMessageReceived()
                
            case .failure(let error):
                Courier.log(String(describing: error))
                self.onMessageReceivedError?(CourierError.inboxWebSocketFail)
            }
            
        }
    }
    
    private func openWebSocket(clientKey: String, userId: String) async throws -> URLSessionWebSocketTask {
        
        // Return the socket if it is created
        if let socket = webSocket {
            return socket
        }
        
        // Create a new socket if needed
        let url = URL(string: "\(inboxWebSocketUrl)/?clientKey=\(clientKey)")!
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let socket = session.webSocketTask(with: request)
        socket.resume()
        
        let dict: [String : Any] = [
            "action": "subscribe",
            "data": [
                "channel": userId,
                "clientKey": clientKey,
                "event": "*",
                "version": "3"
            ]
        ]
        
        let json = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let body = String(data: json ?? Data(), encoding: .utf8) ?? ""
        
        try await socket.send(URLSessionWebSocketTask.Message.string(body))
        
        return socket
        
    }
    
    internal func getMessages(clientKey: String, userId: String, paginationLimit: Int = 24, startCursor: String? = nil) async throws -> InboxData {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<InboxData, Error>) in
            
            let query = """
            query GetMessages(
                $params: FilterParamsInput
                $limit: Int = \(paginationLimit)
                $after: String \(startCursor != nil ? "= \"\(startCursor!)\"" : "")
            ) {
                count(params: $params)
                messages(params: $params, limit: $limit, after: $after) {
                    totalCount
                    pageInfo {
                        startCursor
                        hasNextPage
                    }
                    nodes {
                        messageId
                        read
                        archived
                        created
                        tags
                        title
                        preview
                        actions {
                            content
                            href
                            style
                            background_color
                        }
                    }
                }
            }
            """

            let url = URL(string: inboxUrl)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(clientKey, forHTTPHeaderField: "x-courier-client-key")
            request.addValue(userId, forHTTPHeaderField: "x-courier-user-id")
            
            let payload = CourierGraphQLQuery(query: query)
            request.httpBody = try! JSONEncoder().encode(payload)
            
            let task = CourierTask(with: request) { (validCodes, data, response, error, status) in
                
                if (!validCodes.contains(status)) {
                    continuation.resume(throwing: CourierError.requestError)
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(InboxResponse.self, from: data ?? Data())
                    continuation.resume(returning: res.data)
                } catch {
                    Courier.log(String(describing: error))
                    continuation.resume(throwing: CourierError.requestError)
                }
                
            }
            
            task.start()
            
        })

    }
    
}
