//
//  InboxRepository.swift
//  Courier_iOS
//
//  Created by Michael Miller on 10/2/24.
//

internal class InboxRepository {
    
    var socket: InboxSocket? = nil
    
    private var inboxDataFetchTask: Task<CourierInboxData?, Error>?
    
    enum Pagination: Int {
        case `default` = 32
        case max = 100
        case min = 1
    }
    
    private(set) var isPagingFeed = false
    private(set) var isPagingArchived = false
    
    func endPaging() {
        isPagingFeed = false
        isPagingArchived = false
    }
    
    private var client: CourierClient? {
        get {
            return Courier.shared.client
        }
    }
    
    func stop(with handler: InboxMutationHandler) async {
        
        endPaging()
        
        inboxDataFetchTask?.cancel()
        inboxDataFetchTask = nil
        
        socket?.disconnect()
        socket = nil
        
        socket?.receivedMessage = nil
        socket?.receivedMessageEvent = nil
        
        await handler.onInboxKilled()
        
    }
    
    @discardableResult func get(with handler: InboxMutationHandler, inboxData: CourierInboxData?, isRefresh: Bool) async -> CourierInboxData? {
        
        await stop(with: handler)
        
        await handler.onInboxReload(isRefresh: isRefresh)
        
        inboxDataFetchTask = Task {
            do {
                
                let inboxData = try await getInbox(
                    inboxData: inboxData,
                    isRefresh: isRefresh,
                    onReceivedMessage: { message in
                        Task { await handler.onInboxMessageReceived(message: message) }
                    },
                    onReceivedMessageEvent: { event in
                        Task { await handler.onInboxEventReceived(event: event) }
                    }
                )
                
                guard let data = inboxData else {
                    return nil
                }
                
                await handler.onInboxUpdated(inbox: data)
                
                return data
                
            } catch {
                
                if Task.isCancelled {
                    return nil
                }
                
                await handler.onInboxError(with: error)
                
                return nil
                
            }
        }
        
        do {
            return try await inboxDataFetchTask?.value
        } catch {
            return nil
        }
        
    }
    
    private func getInitialLimit(for set: InboxMessageSet?, isRefresh: Bool) -> Int {
        
        if isRefresh {
            let existingCount = set?.messages.count ?? Courier.shared.paginationLimit
            return min(existingCount, Courier.shared.paginationLimit)
        }
        
        return Courier.shared.paginationLimit
        
    }
    
    private func getInbox(inboxData: CourierInboxData?, isRefresh: Bool, onReceivedMessage: @escaping (InboxMessage) -> Void, onReceivedMessageEvent: @escaping (InboxSocket.MessageEvent) -> Void) async throws -> CourierInboxData? {
        
        try Task.checkCancellation()
         
        if !Courier.shared.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        // Get either the same number of items shown, or the pagination limit
        // This handles the case or refreshes or fresh data pulls
        let feedLimit = getInitialLimit(for: inboxData?.feed, isRefresh: isRefresh)
        let archivedLimit = getInitialLimit(for: inboxData?.archived, isRefresh: isRefresh)
        
        // Functions for getting data
        async let feedTask = client.inbox.getMessages(paginationLimit: feedLimit, startCursor: nil)
        async let archivedTask = client.inbox.getArchivedMessages(paginationLimit: archivedLimit, startCursor: nil)
        async let unreadCountTask = client.inbox.getUnreadMessageCount()
        
        let (feedRes, archivedRes, unreadCount) = try await (
            feedTask,
            archivedTask,
            unreadCountTask
        )
        
        try await connectWebSocket(onReceivedMessage, onReceivedMessageEvent)
        
        return CourierInboxData(
            feed: feedRes.toInboxMessageSet(),
            archived: archivedRes.toInboxMessageSet(),
            unreadCount: unreadCount
        )
        
    }
    
    private func connectWebSocket(_ onReceivedMessage: @escaping (InboxMessage) -> Void, _ onReceivedMessageEvent: @escaping (InboxSocket.MessageEvent) -> Void) async throws {
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        self.socket?.disconnect()
        
        // Create the socket
        self.socket = InboxSocketManager.getSocketInstance(
            options: client.options
        )
        
        // Listen to events
        self.socket?.receivedMessage = onReceivedMessage
        self.socket?.receivedMessageEvent = onReceivedMessageEvent
        
        // Connect the socket subscription
        try await self.socket?.connect()
        try await self.socket?.sendSubscribe()
        
    }
    
    func getNextPage(_ feed: InboxMessageFeed, inboxData: CourierInboxData) async throws -> InboxMessageSet? {
        
        if !Courier.shared.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        let limit = Courier.shared.paginationLimit
        
        if feed == .feed {
            
            if !inboxData.feed.canPaginate || isPagingFeed {
                return nil
            }
            
            self.isPagingFeed = true
            
            let res = try await client.inbox.getMessages(
                paginationLimit: limit,
                startCursor: inboxData.feed.paginationCursor
            )
            
            self.isPagingFeed = false
            
            return res.toInboxMessageSet()
            
        } else {
            
            if !inboxData.archived.canPaginate || isPagingArchived {
                return nil
            }
            
            self.isPagingArchived = true
            
            let res = try await client.inbox.getArchivedMessages(
                paginationLimit: limit,
                startCursor: inboxData.archived.paginationCursor
            )
            
            self.isPagingArchived = false
            
            return res.toInboxMessageSet()
            
        }
        
    }
    
}
