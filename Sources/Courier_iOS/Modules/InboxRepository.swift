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
    
    private(set) var isPaging = false
    
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
    
    private var delegate: InboxDelegate? {
        get {
            return Courier.shared.inboxDelegate
        }
    }
    
    func stop() {
        
        inboxDataFetchTask?.cancel()
        inboxDataFetchTask = nil
        
        socket?.disconnect()
        socket = nil
        
        socket?.receivedMessage = nil
        socket?.receivedMessageEvent = nil
        
        delegate?.onInboxKilled()
        
    }
    
    @discardableResult func get(isRefresh: Bool) async -> CourierInboxData? {
        
        stop()
        
        delegate?.onInboxReload(isRefresh: isRefresh)
        
        inboxDataFetchTask = Task {
            do {
                
                let inboxData = try await getInbox(
                    onReceivedMessage: { [weak self] message in
                        self?.delegate?.onInboxMessageReceived(message: message)
                    },
                    onReceivedMessageEvent: { [weak self] event in
                        self?.handleEvent(event)
                    }
                )
                
                guard let data = inboxData else {
                    return nil
                }
                
                delegate?.onInboxUpdated(inbox: data)
                
                return data
                
            } catch {
                
                if Task.isCancelled {
                    return nil
                }
                
                delegate?.onInboxError(with: error)
                
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
    
    private func handleMessage(_ message: InboxMessage) {
        
        Task {
            
            let inboxFeed: InboxMessageFeed = message.isArchived ? .archived : .feed
            
        }
        
//        await self?.inboxData?.addNewMessage(inboxFeed, message: message)
//        
//        await self?.notifyInboxUpdated()
        
    }
    
    private func handleEvent(_ event: InboxSocket.MessageEvent) {
        
        Task {
         
            switch (event.event) {
            case .markAllRead:
                
                print("markAllRead")
                
                //                    await self?.inboxData?.readAllMessages(.feed)
                //                    await self?.notifyInboxUpdated()
                
            case .read:
                
                print("read")
                
                //                    if let messageId = messageEvent.messageId {
                //                        try await self?.inboxData?.readMessage(.feed, messageId: messageId)
                //                        await self?.notifyInboxUpdated()
                //                    }
                
            case .unread:
                
                print("unread")
                
                //                    if let messageId = messageEvent.messageId {
                //                        try await self?.inboxData?.unreadMessage(.feed, messageId: messageId)
                //                        await self?.notifyInboxUpdated()
                //                    }
                
            case .archive:
                
                print("archive")
                
                //                    if let messageId = messageEvent.messageId {
                //                        try await self?.inboxData?.archiveMessage(.feed, messageId: messageId)
                //                        await self?.notifyInboxUpdated()
                //                    }
                
            case .opened:
                
                print("opened")
                
                //                    if let messageId = messageEvent.messageId {
                //                        try await self?.inboxData?.openMessage(.feed, messageId: messageId)
                //                        await self?.notifyInboxUpdated()
                //                    }
                
            default:
                break
            }
            
        }
        
//        await self?.inboxData?.addNewMessage(inboxFeed, message: message)
//
//        await self?.notifyInboxUpdated()
        
    }
    
}
