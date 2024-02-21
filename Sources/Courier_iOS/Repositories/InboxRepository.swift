//
//  InboxRepository.swift
//  
//
//  Created by https://github.com/mikemilla on 2/23/23.
//

import Foundation

internal class InboxRepository: Repository {
    
    internal func connectInboxWebSocket(clientKey: String, userId: String, onMessageReceived: @escaping (InboxMessage) -> Void, onMessageReceivedError: @escaping (CourierError) -> Void) async throws {
        
        if (CourierInboxWebsocket.shared?.isSocketConnected == true || CourierInboxWebsocket.shared?.isSocketConnecting == true) {
            return
        }
        
        // Listen to new messages from the socket
        CourierInboxWebsocket.onMessageReceived = { text in
            do {
                let dictionary = try (text.data(using: .utf8) ?? Data()).toDictionary()
                let newMessage = InboxMessage(dictionary)
                onMessageReceived(newMessage)
            } catch {
                let e = CourierError(from: error)
                Courier.log(e.message)
                onMessageReceivedError(e)
            }
        }
        
        // Connect the socket
        CourierInboxWebsocket.connect(
            clientKey: clientKey,
            userId: userId
        )
        
    }
    
    internal func closeInboxWebSocket() {
        CourierInboxWebsocket.disconnect()
    }
    
    internal func getMessages(clientKey: String, userId: String, paginationLimit: Int = 24, startCursor: String? = nil) async throws -> InboxData {
        
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
                    opened
                    title
                    preview
                    data
                    actions {
                        content
                        data
                        href
                    }
                    trackingIds {
                        openTrackingId
                        archiveTrackingId
                        clickTrackingId
                        deliverTrackingId
                        readTrackingId
                        unreadTrackingId
                    }
                }
            }
        }
        """
        
        let data = try await graphQLQuery(
            clientKey: clientKey,
            userId: userId,
            url: CourierUrl.inboxGraphQL,
            query: query
        )
        
        do {
            let dictionary = try data?.toDictionary()
            let res = InboxResponse(dictionary)
            guard let data = res.data else { throw CourierError.parsingError }
            return data
        } catch {
            let e = CourierError(from: error)
            Courier.log(e.message)
            throw e
        }

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
        
        let data = try await graphQLQuery(
            clientKey: clientKey,
            userId: userId,
            url: CourierUrl.inboxGraphQL,
            query: query
        )
        
        do {
            let dictionary = try data?.toDictionary()
            let res = InboxResponse(dictionary)
            return res.data?.count ?? 0
        } catch {
            let e = CourierError(from: error)
            Courier.log(e.message)
            throw e
        }

    }
    
    internal func clickMessage(clientKey: String, userId: String, messageId: String, channelId: String) async throws {
        
        let mutation = """
        mutation TrackEvent(
          $messageId: String = \"\(messageId)\"
          $trackingId: String = \"\(channelId)\"
        ) {
          clicked(messageId: $messageId, trackingId: $trackingId)
        }
        """
        
        try await graphQLQuery(
            clientKey: clientKey,
            userId: userId,
            url: CourierUrl.inboxGraphQL,
            query: mutation
        )
        
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
    
    internal func openMessage(clientKey: String, userId: String, messageId: String) async throws {
        
        let mutation = """
        mutation TrackEvent(
          $messageId: String = \"\(messageId)\"
        ) {
          opened(messageId: $messageId)
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
