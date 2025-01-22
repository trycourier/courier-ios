//
//  InboxClient.swift
//
//
//  Created by https://github.com/mikemilla on 7/22/24.
//

import Foundation

public class InboxClient: CourierApiClient {
    
    private let options: CourierClient.Options
    public let socket: InboxSocket
        
    init(options: CourierClient.Options) {
        self.options = options
        self.socket = InboxSocket(options: self.options)
        super.init()
    }
    
    public func getMessage(messageId: String) async throws -> CourierGetInboxMessageResponse {
        
        Logger.warn("🚧 getMessage is under construction and may result in data you do not expect")

        // TODO: Support tenants
//        let tenantParams = options.tenantId != nil ? "accountId: \"\(options.tenantId!)\"" : ""
        
        let query = """
            query GetInboxMessage {
                message(messageId: \"\(messageId)\") {
                    messageId
                    read
                    archived
                    created
                    opened
                    data
                    trackingIds {
                        clickTrackingId
                    }
                    content {
                        title
                        preview
                        actions {
                            background_color
                            content
                            href
                            style
                        }
                    }
                }
            }
        """

        let request = try http(InboxClient.INBOX_GRAPH_QL) {
            
            $0.httpMethod = "POST"
            
            $0.addHeader(key: "x-courier-user-id", value: options.userId)
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            } else if let clientKey = options.clientKey {
                $0.addHeader(key: "x-courier-client-key", value: clientKey)
            }
            
            $0.httpBody = try? query.toGraphQuery()
            
        }
        
        return try await request.dispatch(options)
        
    }
    
    public func getMessages(paginationLimit: Int = 24, startCursor: String? = nil) async throws -> InboxResponse {
        
        let params: String
        if let tenantId = options.tenantId {
            params = "= { accountId: \"\(tenantId)\" }"
        } else {
            params = ""
        }

        let after: String
        if let startCursor = startCursor {
            after = "= \"\(startCursor)\""
        } else {
            after = ""
        }
        
        let query = """
            query GetMessages(
                $params: FilterParamsInput \(params)
                $limit: Int = \(paginationLimit)
                $after: String \(after)
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
                            clickTrackingId
                        }
                    }
                }
            }
        """

        let request = try http(InboxClient.INBOX_GRAPH_QL) {
            
            $0.httpMethod = "POST"
            
            $0.addHeader(key: "x-courier-user-id", value: options.userId)
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            } else if let clientKey = options.clientKey {
                $0.addHeader(key: "x-courier-client-key", value: clientKey)
            }
            
            $0.httpBody = try! query.toGraphQuery()
            
        }
        
        return try await request.dispatch(options)
        
    }
    
    public func getArchivedMessages(paginationLimit: Int = 24, startCursor: String? = nil) async throws -> InboxResponse {
        
        let params: String
        if let tenantId = options.tenantId {
            params = "= { accountId: \"\(tenantId)\", archived: true }"
        } else {
            params = "= { archived: true }"
        }

        let after: String
        if let startCursor = startCursor {
            after = "= \"\(startCursor)\""
        } else {
            after = ""
        }

        let query = """
            query GetArchivedMessages(
                $params: FilterParamsInput \(params)
                $limit: Int = \(paginationLimit)
                $after: String \(after)
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
                            clickTrackingId
                        }
                    }
                }
            }
        """

        let request = try http(InboxClient.INBOX_GRAPH_QL) {
            
            $0.httpMethod = "POST"
            
            $0.addHeader(key: "x-courier-user-id", value: options.userId)
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            } else if let clientKey = options.clientKey {
                $0.addHeader(key: "x-courier-client-key", value: clientKey)
            }
            
            $0.httpBody = try! query.toGraphQuery()
            
        }
        
        return try await request.dispatch(options)
        
    }
    
    public func getUnreadMessageCount() async throws -> Int {
        
        let params: String
        if let tenantId = options.tenantId {
            params = "{ accountId: \"\(tenantId)\", status: \"unread\" }"
        } else {
            params = "{ status: \"unread\" }"
        }
        
        let query = """
            query GetMessages(
                $params: FilterParamsInput = \(params)
            ) {
                count(params: $params)
            }
        """

        let request = try http(InboxClient.INBOX_GRAPH_QL) {
            
            $0.httpMethod = "POST"
            
            $0.addHeader(key: "x-courier-user-id", value: options.userId)
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            } else if let clientKey = options.clientKey {
                $0.addHeader(key: "x-courier-client-key", value: clientKey)
            }
            
            $0.httpBody = try! query.toGraphQuery()
            
        }
        
        let res = try await request.dispatch(options) as InboxResponse
        return res.data?.count ?? 0
        
    }
    
    public func click(messageId: String, trackingId: String) async throws {
        
        let mutation = """
            mutation TrackEvent {
                clicked(messageId: \"\(messageId)\", trackingId: \"\(trackingId)\")
            }
        """

        let request = try http(InboxClient.INBOX_GRAPH_QL) {
            
            $0.httpMethod = "POST"
            
            $0.addHeader(key: "x-courier-user-id", value: options.userId)
            
            if let connectionId = options.connectionId {
                $0.addHeader(key: "x-courier-client-source-id", value: connectionId)
            }
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            } else if let clientKey = options.clientKey {
                $0.addHeader(key: "x-courier-client-key", value: clientKey)
            }
            
            $0.httpBody = try! mutation.toGraphQuery()
            
        }
        
        try await request.dispatch(options)
        
    }
    
    public func read(messageId: String) async throws {
        
        let mutation = """
            mutation TrackEvent {
                read(messageId: \"\(messageId)\")
            }
        """

        let request = try http(InboxClient.INBOX_GRAPH_QL) {
            
            $0.httpMethod = "POST"
            
            $0.addHeader(key: "x-courier-user-id", value: options.userId)
            
            if let connectionId = options.connectionId {
                $0.addHeader(key: "x-courier-client-source-id", value: connectionId)
            }
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            } else if let clientKey = options.clientKey {
                $0.addHeader(key: "x-courier-client-key", value: clientKey)
            }
            
            $0.httpBody = try! mutation.toGraphQuery()
            
        }
        
        try await request.dispatch(options)
        
    }
    
    public func unread(messageId: String) async throws {
        
        let mutation = """
            mutation TrackEvent {
                unread(messageId: \"\(messageId)\")
            }
        """

        let request = try http(InboxClient.INBOX_GRAPH_QL) {
            
            $0.httpMethod = "POST"
            
            $0.addHeader(key: "x-courier-user-id", value: options.userId)
            
            if let connectionId = options.connectionId {
                $0.addHeader(key: "x-courier-client-source-id", value: connectionId)
            }
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            } else if let clientKey = options.clientKey {
                $0.addHeader(key: "x-courier-client-key", value: clientKey)
            }
            
            $0.httpBody = try! mutation.toGraphQuery()
            
        }
        
        try await request.dispatch(options)
        
    }
    
    public func open(messageId: String) async throws {
        
        let mutation = """
            mutation TrackEvent {
                opened(messageId: \"\(messageId)\")
            }
        """

        let request = try http(InboxClient.INBOX_GRAPH_QL) {
            
            $0.httpMethod = "POST"
            
            $0.addHeader(key: "x-courier-user-id", value: options.userId)
            
            if let connectionId = options.connectionId {
                $0.addHeader(key: "x-courier-client-source-id", value: connectionId)
            }
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            } else if let clientKey = options.clientKey {
                $0.addHeader(key: "x-courier-client-key", value: clientKey)
            }
            
            $0.httpBody = try! mutation.toGraphQuery()
            
        }
        
        try await request.dispatch(options)
        
    }
    
    public func archive(messageId: String) async throws {
        
        let mutation = """
            mutation TrackEvent {
                archive(messageId: \"\(messageId)\")
            }
        """

        let request = try http(InboxClient.INBOX_GRAPH_QL) {
            
            $0.httpMethod = "POST"
            
            $0.addHeader(key: "x-courier-user-id", value: options.userId)
            
            if let connectionId = options.connectionId {
                $0.addHeader(key: "x-courier-client-source-id", value: connectionId)
            }
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            } else if let clientKey = options.clientKey {
                $0.addHeader(key: "x-courier-client-key", value: clientKey)
            }
            
            $0.httpBody = try! mutation.toGraphQuery()
            
        }
        
        try await request.dispatch(options)
        
    }
    
    public func readAll() async throws {
        
        let mutation = """
            mutation TrackEvent {
              markAllRead
            }
        """

        let request = try http(InboxClient.INBOX_GRAPH_QL) {
            
            $0.httpMethod = "POST"
            
            $0.addHeader(key: "x-courier-user-id", value: options.userId)
            
            if let connectionId = options.connectionId {
                $0.addHeader(key: "x-courier-client-source-id", value: connectionId)
            }
            
            if let jwt = options.jwt {
                $0.addHeader(key: "Authorization", value: "Bearer \(jwt)")
            } else if let clientKey = options.clientKey {
                $0.addHeader(key: "x-courier-client-key", value: clientKey)
            }
            
            $0.httpBody = try! mutation.toGraphQuery()
            
        }
        
        try await request.dispatch(options)
        
    }
    
}
