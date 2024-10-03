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
    
    private var client: CourierClient? {
        get {
            return Courier.shared.client
        }
    }
    
    private var limit: Int {
        get {
            return Courier.shared.inboxPaginationLimit
        }
    }
    
    private func getDelegate() -> InboxSharedDataMutations? {
        return Courier.shared.inboxMutationHandler
    }
    
    func stop() async {
        
        inboxDataFetchTask?.cancel()
        inboxDataFetchTask = nil
        
        socket?.disconnect()
        socket = nil
        
        socket?.receivedMessage = nil
        socket?.receivedMessageEvent = nil
        
        await getDelegate()?.onInboxKilled()
        
    }
    
    @discardableResult func get(isRefresh: Bool) async -> CourierInboxData? {
        
        await stop()
        
        await getDelegate()?.onInboxReload(isRefresh: isRefresh)
        
        inboxDataFetchTask = Task {
            do {
                
                let inboxData = try await getInbox(
                    onReceivedMessage: { [weak self] message in
                        Task { await self?.getDelegate()?.onInboxMessageReceived(message: message) }
                    },
                    onReceivedMessageEvent: { [weak self] event in
                        Task { await self?.getDelegate()?.onInboxEventReceived(event: event) }
                    }
                )
                
                guard let data = inboxData else {
                    return nil
                }
                
                await getDelegate()?.onInboxUpdated(inbox: data)
                
                return data
                
            } catch {
                
                if Task.isCancelled {
                    return nil
                }
                
                await getDelegate()?.onInboxError(with: error)
                
                return nil
                
            }
        }
        
        do {
            return try await inboxDataFetchTask?.value
        } catch {
            return nil
        }
        
    }
    
    private func getInbox(onReceivedMessage: @escaping (InboxMessage) -> Void, onReceivedMessageEvent: @escaping (InboxSocket.MessageEvent) -> Void) async throws -> CourierInboxData? {
        
        try Task.checkCancellation()
         
        if !Courier.shared.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        // Functions for getting data
        async let feedTask = client.inbox.getMessages(paginationLimit: limit, startCursor: nil)
        async let archivedTask = client.inbox.getArchivedMessages(paginationLimit: limit, startCursor: nil)
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
