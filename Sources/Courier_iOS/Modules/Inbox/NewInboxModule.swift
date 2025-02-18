//
//  NewInboxModule.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/14/25.
//

@CourierActor
internal class NewInboxModule: InboxDataStoreEventDelegate {
    
    enum Pagination: Int {
        case `default` = 32
        case max = 100
        case min = 1
    }
    
    let courier: Courier
    let dataStore = InboxDataStore()
    let dataService = InboxDataService()
    
    var paginationLimit: Int = Pagination.default.rawValue
    
    init(courier: Courier) {
        self.courier = courier
        self.dataStore.delegate = self
    }
    
    // MARK: Fetching
    
    private func getInitialLimit(messageCount: Int?, isRefresh: Bool) -> Int {
        
        if isRefresh {
            let existingCount = messageCount ?? paginationLimit
            return max(existingCount, paginationLimit)
        }
        
        return paginationLimit
        
    }
    
    func getInbox(isRefresh: Bool) async throws {
        
        await dataService.stop()
        
        if !self.courier.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = self.courier.client else {
            throw CourierError.inboxNotInitialized
        }
        
        do {
            
            await dataStore.delegate?.onLoading(isRefresh)
            
            // Get the pagination limits
            let feedPaginationLimit = getInitialLimit(
                messageCount: dataStore.feed.messages.count,
                isRefresh: isRefresh
            )
            
            let archivePaginationLimit = getInitialLimit(
                messageCount: dataStore.archive.messages.count,
                isRefresh: isRefresh
            )
            
            // Get the inbox data
            let data = try await dataService.getInboxData(
                client: client,
                feedPaginationLimit: feedPaginationLimit,
                archivePaginationLimit: archivePaginationLimit,
                isRefresh: isRefresh
            )
            
            // Connect the socket
            try await dataService.connectWebSocket(
                client: client,
                onReceivedMessage: { [weak self] message in
                    Task { await self?.dataStore.addMessage(message, at: 0, to: .feed) }
                },
                onReceivedMessageEvent: { [weak self] event in
                    Task {
                        switch event.event {
                        case .markAllRead:
                            await self?.dataStore.readAllMessages()
                        case .read:
                            guard let messageId = event.messageId else { return }
                            let message = InboxMessage(messageId: messageId)
                            await self?.dataStore.readMessage(message, from: .feed)
                            await self?.dataStore.readMessage(message, from: .archived)
                        case .unread:
                            guard let messageId = event.messageId else { return }
                            let message = InboxMessage(messageId: messageId)
                            await self?.dataStore.unreadMessage(message, from: .feed)
                            await self?.dataStore.unreadMessage(message, from: .archived)
                        case .opened:
                            guard let messageId = event.messageId else { return }
                            let message = InboxMessage(messageId: messageId)
                            await self?.dataStore.openMessage(message, from: .feed)
                            await self?.dataStore.openMessage(message, from: .archived)
                        case .unopened:
                            break
                        case .archive:
                            guard let messageId = event.messageId else { return }
                            let message = InboxMessage(messageId: messageId)
                            await self?.dataStore.archiveMessage(message, from: .feed)
                            await self?.dataStore.archiveMessage(message, from: .archived)
                        case .unarchive:
                            break
                        case .click:
                            break
                        case .unclick:
                            break
                        }
                    }
                }
            )
            
            // Hit all callbacks
            await dataStore.updateDataSet(data.feed, for: .feed)
            await dataStore.updateDataSet(data.archived, for: .archived)
            await dataStore.updateUnreadCount(data.unreadCount)
            
        } catch {
            
            await dataStore.delegate?.onError(error)
            
        }
        
    }
    
    // MARK: Listeners
    
    var inboxListeners: [NewCourierInboxListener] = []
    
    func addListener(_ listener: NewCourierInboxListener) {
        self.inboxListeners.append(listener)
        self.courier.client?.log("Courier Inbox Listener Registered. Total Listeners: \(self.inboxListeners.count)")
    }
    
    func removeListener(_ listener: NewCourierInboxListener) {
        self.inboxListeners.removeAll(where: { return $0 == listener })
        self.courier.client?.log("Courier Inbox Listener Unregistered. Total Listeners: \(self.inboxListeners.count)")
    }
    
    func removeAllListeners() {
        self.inboxListeners.removeAll()
        self.courier.client?.log("Courier Inbox Listeners Removed. Total Listeners: \(self.inboxListeners.count)")
    }
    
    func dispose() async {
        await self.dataStore.dispose()
        self.removeAllListeners()
    }
    
    // MARK: DataStore Events
    
    func onLoading(_ isRefresh: Bool) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onLoading?(isRefresh)
            }
        }
    }
    
    func onError(_ error: any Error) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onError?(error)
            }
        }
    }
    
    func onMessagesChanged(_ messages: [InboxMessage], _ canPaginate: Bool, for feed: InboxMessageFeed) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onMessagesChanged?(messages, canPaginate, feed)
            }
        }
    }
    
    func onMessageEvent(_ message: InboxMessage, at index: Int, to feed: InboxMessageFeed, event: InboxMessageEvent) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onMessageEvent?(message, index, feed, event)
            }
        }
    }
    
    func onTotalCountUpdated(totalCount: Int, to feed: InboxMessageFeed) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onTotalCountChanged?(totalCount, feed)
            }
        }
    }
    
    func onUnreadCountUpdated(unreadCount: Int) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onUnreadCountChanged?(unreadCount)
            }
        }
    }
    
}
