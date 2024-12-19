//
//  InboxRepository.swift
//  Courier_iOS
//
//  Created by Michael Miller on 10/2/24.
//

internal actor InboxRepository {
    
    private let inboxSocketManager = InboxSocketManager()
    
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
        get async {
            return await Courier.shared.client
        }
    }
    
    func stop(with handler: InboxMutationHandler) async {
        endPaging()
        await inboxSocketManager.closeSocket()
        await handler.onInboxKilled()
    }
    
    @discardableResult func get(with handler: InboxMutationHandler, inboxData: CourierInboxData?, isRefresh: Bool) async -> CourierInboxData? {
        
        await stop(with: handler)
        
        await handler.onInboxReload(isRefresh: isRefresh)
        
        do {
            
            let inboxData = try await getInbox(
                inboxData: inboxData,
                isRefresh: isRefresh
            )
            
            try await connectWebSocket(
                onReceivedMessage: { message in
                    Task { await handler.onInboxMessageReceived(message: message) }
                },
                onReceivedMessageEvent: { event in
                    Task { await handler.onInboxEventReceived(event: event) }
                }
            )
            
            await handler.onInboxUpdated(inbox: inboxData)

            return inboxData
            
        } catch {
            
            await handler.onInboxError(with: error)
            
            return nil
            
        }
        
    }
    
    private func getInitialLimit(for set: InboxMessageSet?, isRefresh: Bool) async -> Int {
        
        let defaultPaginationLimit = await Courier.shared.paginationLimit
        
        if isRefresh {
            let existingCount = set?.messages.count ?? defaultPaginationLimit
            return max(existingCount, defaultPaginationLimit)
        }
        
        return defaultPaginationLimit
        
    }
    
    private func getInbox(inboxData: CourierInboxData?, isRefresh: Bool) async throws -> CourierInboxData {
         
        if await !Courier.shared.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = await client else {
            throw CourierError.inboxNotInitialized
        }
        
        // Get either the same number of items shown, or the pagination limit
        // This handles the case or refreshes or fresh data pulls
        let feedLimit = await getInitialLimit(for: inboxData?.feed, isRefresh: isRefresh)
        let archivedLimit = await getInitialLimit(for: inboxData?.archived, isRefresh: isRefresh)
        
        // Functions for getting data
        async let feedTask = client.inbox.getMessages(paginationLimit: feedLimit, startCursor: nil)
        async let archivedTask = client.inbox.getArchivedMessages(paginationLimit: archivedLimit, startCursor: nil)
        async let unreadCountTask = client.inbox.getUnreadMessageCount()
        
        let (feedRes, archivedRes, unreadCount) = try await (
            feedTask,
            archivedTask,
            unreadCountTask
        )
        
        return CourierInboxData(
            feed: feedRes.toInboxMessageSet(),
            archived: archivedRes.toInboxMessageSet(),
            unreadCount: unreadCount
        )
        
    }
    
    private func connectWebSocket(onReceivedMessage: @escaping (InboxMessage) -> Void, onReceivedMessageEvent: @escaping (InboxSocket.MessageEvent) -> Void) async throws {
        
        guard let client = await client else {
            throw CourierError.inboxNotInitialized
        }
        
        // Create the socket if needed
        let socket = await inboxSocketManager.updateInstance(
            options: client.options
        )
        
        // Listen to events
        socket.receivedMessage = onReceivedMessage
        socket.receivedMessageEvent = onReceivedMessageEvent
        
        // Connect the socket subscription
        try await socket.connect()
        try await socket.sendSubscribe()
        
        // Ensure the socket is kept alive
        socket.keepAlive()
        
    }
    
    func getNextPage(_ feed: InboxMessageFeed, inboxData: CourierInboxData) async throws -> InboxMessageSet? {
        
        if await !Courier.shared.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = await client else {
            throw CourierError.inboxNotInitialized
        }
        
        let limit = await Courier.shared.paginationLimit
        
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
