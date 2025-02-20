//
//  InboxDataService.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/18/25.
//

@CourierActor internal class InboxDataService {
    
    private let inboxSocketManager = InboxSocketManager()
    private(set) var isPagingFeed = false
    private(set) var isPagingArchived = false
    
    func endPaging() {
        isPagingFeed = false
        isPagingArchived = false
    }
    
    func stop() async {
        endPaging()
        await inboxSocketManager.closeSocket()
    }
    
    func getInboxData(client: CourierClient, feedPaginationLimit: Int, archivePaginationLimit: Int, isRefresh: Bool) async throws -> (feed: InboxMessageSet, archive: InboxMessageSet, unreadCount: Int) {
        
        var feedRes: InboxResponse?
        var archivedRes: InboxResponse?
        var unreadCount: Int?

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                feedRes = try await client.inbox.getMessages(
                    paginationLimit: feedPaginationLimit,
                    startCursor: nil
                )
            }
            group.addTask {
                archivedRes = try await client.inbox.getArchivedMessages(
                    paginationLimit: archivePaginationLimit,
                    startCursor: nil
                )
            }
            group.addTask {
                unreadCount = try await client.inbox.getUnreadMessageCount()
            }
            try await group.waitForAll()
        }

        guard
            let feedRes = feedRes,
            let archivedRes = archivedRes,
            let unreadCount = unreadCount
        else {
            throw CourierError.inboxNotInitialized
        }
        
        return (feedRes.toInboxMessageDataSet(), archivedRes.toInboxMessageDataSet(), unreadCount)
        
    }
    
    func connectWebSocket(client: CourierClient, onReceivedMessage: @escaping (InboxMessage) -> Void, onReceivedMessageEvent: @escaping (InboxSocket.MessageEvent) -> Void) async throws {
        
        // Create the socket if needed
        let socket = await inboxSocketManager.updateInstance(
            options: client.options
        )
        
        // Connect the socket subscription
        try await socket.connect(
            receivedMessage: onReceivedMessage,
            receivedMessageEvent: onReceivedMessageEvent
        )
        
        try await socket.sendSubscribe()
        
        // Ensure the socket is kept alive
        // Will ping every 5 minutes
        await socket.keepAlive()
        
    }
    
    func getNextFeedPage(client: CourierClient, paginationLimit: Int, paginationCursor: String) async throws -> InboxMessageSet {
        
        self.isPagingFeed = true
        
        let res = try await client.inbox.getMessages(
            paginationLimit: paginationLimit,
            startCursor: paginationCursor
        )
        
        self.isPagingFeed = false
        
        return res.toInboxMessageDataSet()
        
    }
    
    func getNextArchivePage(client: CourierClient, paginationLimit: Int, paginationCursor: String) async throws -> InboxMessageSet {
        
        self.isPagingArchived = true
        
        let res = try await client.inbox.getArchivedMessages(
            paginationLimit: paginationLimit,
            startCursor: paginationCursor
        )
        
        self.isPagingArchived = false
        
        return res.toInboxMessageDataSet()
        
    }
    
}
