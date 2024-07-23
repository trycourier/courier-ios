//
//  InboxClient.swift
//
//
//  Created by Michael Miller on 7/22/24.
//

import Foundation

class InboxClient: CourierApiClient {
    
    private let options: CourierClient.Options
        
    init(options: CourierClient.Options) {
        self.options = options
        super.init()
    }
    
    func getMessage(messageId: String) async throws -> InboxClient.CourierGetInboxMessageResponse {
        
        options.warn("🚧 getMessage is under construction and may result in data you do not expect")

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
        
        let data = try await request.dispatch(options)
        
        do {
            let dictionary = try data.toDictionary()
            return InboxClient.CourierGetInboxMessageResponse(dictionary)
        } catch {
            let e = CourierError(from: error)
            options.error(e.message)
            throw e
        }
        
    }
    
    func getMessages(paginationLimit: Int = 24, startCursor: String? = nil) async throws -> InboxResponse {
        
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
        
        let data = try await request.dispatch(options)
        
        do {
            let dictionary = try data.toDictionary()
            return InboxResponse(dictionary)
        } catch {
            let e = CourierError(from: error)
            options.error(e.message)
            throw e
        }
        
    }
    
    func getArchivedMessages(paginationLimit: Int = 24, startCursor: String? = nil) async throws -> InboxResponse {
        
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
        
        let data = try await request.dispatch(options)
        
        do {
            let dictionary = try data.toDictionary()
            return InboxResponse(dictionary)
        } catch {
            let e = CourierError(from: error)
            options.error(e.message)
            throw e
        }
        
    }
    
    func getUnreadMessageCount() async throws -> Int {
        
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
        
        let data = try await request.dispatch(options)
        
        do {
            let dictionary = try data.toDictionary()
            let res = InboxResponse(dictionary)
            return res.data?.count ?? 0
        } catch {
            let e = CourierError(from: error)
            options.error(e.message)
            throw e
        }
        
    }
    
    func click(messageId: String, trackingId: String) async throws {
        
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
    
    func read(messageId: String) async throws {
        
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
    
    func unread(messageId: String) async throws {
        
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
    
    func open(messageId: String) async throws {
        
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
    
    func archive(messageId: String) async throws {
        
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
    
    func readAll() async throws {
        
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

// MARK: Response Payloads

extension InboxClient {
    
    @objc class CourierGetInboxMessageResponse: NSObject {
        
        let data: GetInboxMessageData?
        
        init(_ dictionary: [String : Any]?) {
            let data = dictionary?["data"] as? [String: Any]
            self.data = GetInboxMessageData(data)
        }
        
    }

    @objc class GetInboxMessageData: NSObject {
        
        var message: InboxMessage?
        
        init(_ dictionary: [String : Any]?) {
            let message = dictionary?["message"] as? [String : Any]
            self.message = InboxMessage(message)
        }
        
    }
    
}
