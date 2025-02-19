//
//  InboxRepository.swift
//  Courier_iOS
//
//  Created by https://github.com/mikemilla on 10/2/24.
//

@CourierActor internal class InboxRepository {
    
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
        get {
            return Courier.shared.client
        }
    }
    
    func stop(with handler: InboxMutationHandler) async {
        endPaging()
        await inboxSocketManager.closeSocket()
        await handler.onInboxKilled()
    }
    
    @discardableResult func get(with handler: InboxMutationHandler, feedMessageCount: Int?, archiveMessageCount: Int?, isRefresh: Bool) async -> CourierInboxData? {
        
        await stop(with: handler)
        
        await handler.onInboxReload(isRefresh: isRefresh)
        
        do {
            
            let inboxData = try await getInbox(
                feedMessageCount: feedMessageCount,
                archiveMessageCount: archiveMessageCount,
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
    
    private func getInitialLimit(messageCount: Int?, isRefresh: Bool) async -> Int {
        
//        let defaultPaginationLimit = Courier.shared.paginationLimit
//        
//        if isRefresh {
//            let existingCount = messageCount ?? defaultPaginationLimit
//            return max(existingCount, defaultPaginationLimit)
//        }
        
        return 100
        
    }
    
    private func getInbox(feedMessageCount: Int?, archiveMessageCount: Int?, isRefresh: Bool) async throws -> CourierInboxData {
         
        if !Courier.shared.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        // Make a strong local copy to ensure it is not deallocated mid-call
        let strongClient = client
        
        // Get either the same number of items shown, or the pagination limit
        // This handles the case or refreshes or fresh data pulls
        let feedLimit = await getInitialLimit(
            messageCount: feedMessageCount,
            isRefresh: isRefresh
        )
        let archivedLimit = await getInitialLimit(
            messageCount: archiveMessageCount,
            isRefresh: isRefresh
        )
        
        var feedRes: InboxResponse?
        var archivedRes: InboxResponse?
        var unreadCount: Int?

        try await withThrowingTaskGroup(of: Void.self) { group in
            
            // Get feed
            group.addTask {
                feedRes = try await strongClient.inbox.getMessages(
                    paginationLimit: feedLimit,
                    startCursor: nil
                )
            }
            
            // Get archived
            group.addTask {
                archivedRes = try await strongClient.inbox.getArchivedMessages(
                    paginationLimit: archivedLimit,
                    startCursor: nil
                )
            }
            
            // Get unread count
            group.addTask {
                unreadCount = try await strongClient.inbox.getUnreadMessageCount()
            }
            
            // Wait for all tasks to finish or one to throw
            try await group.waitForAll()
        }

        guard
            let feedRes = feedRes,
            let archivedRes = archivedRes,
            let unreadCount = unreadCount
        else {
            throw CourierError.inboxNotInitialized
        }

        return CourierInboxData(
            feed: feedRes.toInboxMessageSet(),
            archived: archivedRes.toInboxMessageSet(),
            unreadCount: unreadCount
        )
        
    }
    
    private func connectWebSocket(onReceivedMessage: @escaping (InboxMessage) -> Void, onReceivedMessageEvent: @escaping (InboxSocket.MessageEvent) -> Void) async throws {
        
        guard let client = client else {
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
        // Will ping every 5 minutes
        await socket.keepAlive()
        
    }
    
    func getNextPage(_ feed: InboxMessageFeed, inboxData: CourierInboxData) async throws -> InboxMessageSet? {
        
        if !Courier.shared.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        // Create strong ref copy
        let strongClient = client
        
        let limit = Courier.shared.inboxPaginationLimit
        
        if feed == .feed {
            
            if !inboxData.feed.canPaginate || isPagingFeed {
                return nil
            }
            
            self.isPagingFeed = true
            
            let res = try await strongClient.inbox.getMessages(
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
            
            let res = try await strongClient.inbox.getArchivedMessages(
                paginationLimit: limit,
                startCursor: inboxData.archived.paginationCursor
            )
            
            self.isPagingArchived = false
            
            return res.toInboxMessageSet()
            
        }
        
    }
    
}
