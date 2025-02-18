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
    
    func getInboxData(client: CourierClient, feedPaginationLimit: Int, archivePaginationLimit: Int, isRefresh: Bool) async throws -> (feed: InboxMessageDataSet, archived: InboxMessageDataSet, unreadCount: Int) {
        
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
//    
//    func getNextPage(_ feed: InboxMessageFeed, inboxData: CourierInboxData) async throws -> InboxMessageSet? {
//        
//        if !Courier.shared.isUserSignedIn {
//            throw CourierError.userNotFound
//        }
//        
//        guard let client = client else {
//            throw CourierError.inboxNotInitialized
//        }
//        
//        // Create strong ref copy
//        let strongClient = client
//        
//        let limit = Courier.shared.paginationLimit
//        
//        if feed == .feed {
//            
//            if !inboxData.feed.canPaginate || isPagingFeed {
//                return nil
//            }
//            
//            self.isPagingFeed = true
//            
//            let res = try await strongClient.inbox.getMessages(
//                paginationLimit: limit,
//                startCursor: inboxData.feed.paginationCursor
//            )
//            
//            self.isPagingFeed = false
//            
//            return res.toInboxMessageSet()
//            
//        } else {
//            
//            if !inboxData.archived.canPaginate || isPagingArchived {
//                return nil
//            }
//            
//            self.isPagingArchived = true
//            
//            let res = try await strongClient.inbox.getArchivedMessages(
//                paginationLimit: limit,
//                startCursor: inboxData.archived.paginationCursor
//            )
//            
//            self.isPagingArchived = false
//            
//            return res.toInboxMessageSet()
//            
//        }
//        
//    }
    
}
