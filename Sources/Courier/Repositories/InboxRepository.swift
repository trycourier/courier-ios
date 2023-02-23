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
    
    internal func createWebSocket(clientKey: String, userId: String, onMessageReceived: @escaping (InboxMessage) -> Void) async throws {
        
        webSocket = openWebSocket(clientKey: clientKey)
        
        if let socket = webSocket {
            
            socket.receive { result in
                
                switch result {
                    
                case .failure(let error):
                    
                    print(error) // TODO
                    
                case .success(let message):
                    
                    switch message {
                        
                    case .data(let data):
                        
                        do {
                            let newMessage = try JSONDecoder().decode(InboxMessage.self, from: data)
                            onMessageReceived(newMessage)
                        } catch {
    //                        Courier.log(String(describing: error))
    //                        continuation.resume(throwing: CourierError.requestError)
                        }
                        
                    case .string(let str):
                        
                        do {
                            let data = str.data(using: .utf8) ?? Data()
                            let newMessage = try JSONDecoder().decode(InboxMessage.self, from: data)
                            onMessageReceived(newMessage)
                        } catch {
    //                        Courier.log(String(describing: error))
    //                        continuation.resume(throwing: CourierError.requestError)
                        }
                        
                    @unknown default:
                        break
                    }
                    
                }
                
            }
            
            try await subscribeWebSocket(
                webSocket: socket,
                clientKey: clientKey,
                userId: userId
            )
            
        }
        
    }
    
    internal func closeWebSocket() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
    }
    
    private func openWebSocket(clientKey: String) -> URLSessionWebSocketTask {
        
        let url = URL(string: "wss://1x60p1o3h8.execute-api.us-east-1.amazonaws.com/production/?clientKey=\(clientKey)")!
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let socket = session.webSocketTask(with: request)
        socket.resume()
        
        return socket
        
    }
    
    private func subscribeWebSocket(webSocket: URLSessionWebSocketTask, clientKey: String, userId: String) async throws {
        
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
        
        try await webSocket.send(URLSessionWebSocketTask.Message.string(body))
        
    }
    
    internal func getMessages(clientKey: String, userId: String) async throws -> [InboxMessage] {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<[InboxMessage], Error>) in
            
            let query = """
            query GetMessages(
                $params: FilterParamsInput
                $limit: Int = 10
                $after: String
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
                    continuation.resume(returning: res.data.messages.nodes)
                } catch {
                    Courier.log(String(describing: error))
                    continuation.resume(throwing: CourierError.requestError)
                }
                
            }
            
            task.start()
            
        })

    }
    
}
