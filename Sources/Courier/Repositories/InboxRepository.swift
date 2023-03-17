//
//  InboxRepository.swift
//  
//
//  Created by https://github.com/mikemilla on 2/23/23.
//

import Foundation

internal class InboxRepository: Repository, URLSessionWebSocketDelegate {
    
    private(set) var webSocket: URLSessionWebSocketTask?
    private var onMessageReceived: ((InboxMessage) -> Void)?
    private var onMessageReceivedError: ((CourierError) -> Void)?
    
    internal func createWebSocket(clientKey: String, userId: String, onMessageReceived: @escaping (InboxMessage) -> Void, onMessageReceivedError: @escaping (CourierError) -> Void) async throws {
        
        // Open and connect to the server
        self.webSocket = try await openWebSocket(
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
                        Courier.log(error.friendlyMessage)
                        self.onMessageReceivedError?(CourierError.inboxWebSocketError)
                    }
                case .data(_):
                    break
                @unknown default:
                    break
                }
                
                self.handleMessageReceived()
                
            case .failure(let error):
                Courier.log(error.friendlyMessage)
                self.onMessageReceivedError?(CourierError.inboxWebSocketDisconnect)
            }
            
        }
    }
    
    private func openWebSocket(clientKey: String, userId: String) async throws -> URLSessionWebSocketTask {
        
        // Return the socket if it is created
        if let socket = webSocket {
            return socket
        }
        
        // Create a new socket if needed
        let url = URL(string: "\(CourierUrl.inboxWebSocket)/?clientKey=\(clientKey)")!
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
                "version": "4"
            ]
        ]
        
        let json = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let body = String(data: json ?? Data(), encoding: .utf8) ?? ""
        
        try await socket.send(URLSessionWebSocketTask.Message.string(body))
        
        return socket
        
    }
    
    internal func getAllMessages(clientKey: String, userId: String, paginationLimit: Int = 24, startCursor: String? = nil) async throws -> InboxData {
        
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
        
        let response = try await graphQLQuery(
            InboxResponse.self,
            clientKey: clientKey,
            userId: userId,
            url: CourierUrl.inboxGraphQL,
            query: query
        )
        
        return response.data

    }
    
    internal func getUnreadMessageCount(clientKey: String, userId: String, startCursor: String? = nil) async throws -> Int {
        
        let query = """
        query GetMessages(
            $params: FilterParamsInput = { status: "unread" }
            $limit: Int = \(1)
            $after: String
        ) {
            count(params: $params)
            messages(params: $params, limit: $limit, after: $after) {
                nodes {
                    messageId
                }
            }
        }
        """
        
        let response = try await graphQLQuery(
            InboxResponse.self,
            clientKey: clientKey,
            userId: userId,
            url: CourierUrl.inboxGraphQL,
            query: query
        )
        
        return response.data.count ?? 0

    }
    
    internal func readMessage(clientKey: String, userId: String, messageId: String) async throws {
        
        let mutation = """
        mutation TrackEvent(
          $messageId: String = \"\(messageId)\"
        ) {
          read(messageId: $messageId)
        }
        """
        
        try await graphQLQuery(
            clientKey: clientKey,
            userId: userId,
            url: CourierUrl.inboxGraphQL,
            query: mutation
        )
        
    }
    
    internal func unreadMessage(clientKey: String, userId: String, messageId: String) async throws {
        
        let mutation = """
        mutation TrackEvent(
          $messageId: String = \"\(messageId)\"
        ) {
          unread(messageId: $messageId)
        }
        """
        
        try await graphQLQuery(
            clientKey: clientKey,
            userId: userId,
            url: CourierUrl.inboxGraphQL,
            query: mutation
        )
        
    }
    
    internal func readAllMessages(clientKey: String, userId: String) async throws {
        
        let mutation = """
        mutation TrackEvent {
            markAllRead
        }
        """
        
        try await graphQLQuery(
            clientKey: clientKey,
            userId: userId,
            url: CourierUrl.inboxGraphQL,
            query: mutation
        )
        
    }
    
}
