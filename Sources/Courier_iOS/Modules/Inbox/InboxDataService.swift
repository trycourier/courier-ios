//
//  InboxDataService.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/18/25.
//

@CourierActor internal class InboxDataService {
    
    let inboxSocketManager = InboxSocketManager()
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
        
        async let feedRes = client.inbox.getMessages(
            paginationLimit: feedPaginationLimit,
            startCursor: nil
        )
        async let archivedRes = client.inbox.getArchivedMessages(
            paginationLimit: archivePaginationLimit,
            startCursor: nil
        )
        async let unreadCount = client.inbox.getUnreadMessageCount()

        let (feed, archive, unread) = try await (feedRes, archivedRes, unreadCount)

        return (
            feed.toInboxMessageDataSet(),
            archive.toInboxMessageDataSet(),
            unread
        )
        
    }
    
    func connectWebSocket(client: CourierClient, onReceivedMessage: @escaping @Sendable (InboxMessage) -> Void, onReceivedMessageEvent: @escaping @Sendable (InboxSocket.MessageEvent) -> Void) async throws {
        
        // Create the socket if needed
        let socket = await inboxSocketManager.updateInstance(
            options: client.options
        )
        
        // Connect the socket subscription
        try await socket.connect(
            receivedMessage: onReceivedMessage,
            receivedMessageEvent: onReceivedMessageEvent
        )
        guard await dropIfReplaced(socket) == false else { return }
        
        try await socket.sendSubscribe()
        guard await dropIfReplaced(socket) == false else { return }
        
        // Ensure the socket is kept alive
        // Will ping every 5 minutes
        await socket.keepAlive()
        
    }
    
    // This actor runs other work at each await, so another load or a stop can replace or close
    // this socket while it connects. Closing it before its task exists does nothing, so a socket
    // that's no longer current is closed here. Otherwise it stays connected, untracked, and every
    // message arrives twice.
    private func dropIfReplaced(_ socket: InboxSocket) async -> Bool {
        guard inboxSocketManager.socket !== socket else { return false }
        await socket.disconnect()
        await socket.clearHandlers()
        return true
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
