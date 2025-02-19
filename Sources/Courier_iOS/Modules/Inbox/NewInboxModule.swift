//
//  NewInboxModule.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/14/25.
//

import Foundation

@CourierActor
internal class NewInboxModule: InboxDataStoreEventDelegate {
    
    enum Pagination: Int {
        case `default` = 32
        case max = 100
        case min = 1
    }
    
    enum State {
        case uninitialized
        case fetching
        case initialized
    }
    
    let courier: Courier
    let dataStore = InboxDataStore()
    let dataService = InboxDataService()
    
    var state: State = .uninitialized
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
    
    func getInbox(isRefresh: Bool) async {
        
        do {
            
            await dataService.stop()
            
            if self.inboxListeners.isEmpty {
                throw CourierError.inboxNotInitialized
            }
            
            if !self.courier.isUserSignedIn {
                throw CourierError.userNotFound
            }
            
            guard let client = self.courier.client else {
                throw CourierError.inboxNotInitialized
            }
            
            self.state = .fetching
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
            let snapshot = try await dataService.getInboxData(
                client: client,
                feedPaginationLimit: feedPaginationLimit,
                archivePaginationLimit: archivePaginationLimit,
                isRefresh: isRefresh
            )
            
            // Connect the socket
            try await dataService.connectWebSocket(
                client: client,
                onReceivedMessage: { [weak self] message in
                    Task {
                        await self?.dataStore.addMessage(message, at: 0, to: .feed)
                    }
                },
                onReceivedMessageEvent: { [weak self] event in
                    Task {
                        switch event.event {
                        case .markAllRead:
                            await self?.dataStore.readAllMessages(client: nil)
                        case .read:
                            guard let messageId = event.messageId else { return }
                            let message = InboxMessage(messageId: messageId)
                            await self?.dataStore.readMessage(message, from: .feed, client: nil)
                            await self?.dataStore.readMessage(message, from: .archived, client: nil)
                        case .unread:
                            guard let messageId = event.messageId else { return }
                            let message = InboxMessage(messageId: messageId)
                            await self?.dataStore.unreadMessage(message, from: .feed, client: nil)
                            await self?.dataStore.unreadMessage(message, from: .archived, client: nil)
                        case .opened:
                            guard let messageId = event.messageId else { return }
                            let message = InboxMessage(messageId: messageId)
                            await self?.dataStore.openMessage(message, from: .feed, client: nil)
                            await self?.dataStore.openMessage(message, from: .archived, client: nil)
                        case .unopened:
                            break
                        case .archive:
                            guard let messageId = event.messageId else { return }
                            let message = InboxMessage(messageId: messageId)
                            await self?.dataStore.archiveMessage(message, from: .feed, client: nil)
                            await self?.dataStore.archiveMessage(message, from: .archived, client: nil)
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
            
            await dataStore.reloadSnapshot(snapshot)
            self.state = .initialized
            
        } catch {
            
            await dataStore.delegate?.onError(error)
            self.state = .uninitialized
            
        }
        
    }
    
    func getNextPage(feedType: InboxMessageFeed) async throws -> InboxMessageDataSet? {
        
        if self.inboxListeners.isEmpty {
            return nil
        }
        
        if !self.courier.isUserSignedIn {
            return nil
        }
        
        guard let client = self.courier.client else {
            return nil
        }
        
        let limit = paginationLimit
        
        switch feedType {
        case .feed:
            
            if !dataStore.feed.canPaginate {
                return nil
            }
            
            guard let cursor = dataStore.feed.paginationCursor else {
                return nil
            }
            
            return try await dataService.getNextFeedPage(
                client: client,
                paginationLimit: limit,
                paginationCursor: cursor
            )
            
        case .archived:
            
            if !dataStore.archive.canPaginate {
                return nil
            }
            
            guard let cursor = dataStore.archive.paginationCursor else {
                return nil
            }
            
            return try await dataService.getNextFeedPage(
                client: client,
                paginationLimit: limit,
                paginationCursor: cursor
            )
            
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
    
    func removeAllListeners() async {
        self.inboxListeners.removeAll()
        self.courier.client?.log("Courier Inbox Listeners Removed. Total Listeners: \(self.inboxListeners.count)")
        await self.dataService.stop()
    }
    
    func dispose() async {
        await self.dataStore.dispose()
        await self.removeAllListeners()
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
    
    func onPageAdded(_ messages: [InboxMessage], _ canPaginate: Bool, for feed: InboxMessageFeed) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onMessagesChanged?(messages, canPaginate, feed)
            }
        }
    }
    
}

@CourierActor extension Courier {
    
    public var feedMessages: [InboxMessage] {
        get {
            return inboxModule.dataStore.feed.messages
        }
    }
    
    public var archivedMessages: [InboxMessage] {
        get {
            return inboxModule.dataStore.archive.messages
        }
    }
    
    public var inboxPaginationLimit: Int {
        get {
            return inboxModule.paginationLimit
        }
    }
    
    @objc public func setPaginationLimit(_ limit: Int) {
        let min = min(InboxRepository.Pagination.max.rawValue, limit)
        self.inboxModule.paginationLimit = max(InboxRepository.Pagination.min.rawValue, min)
    }
    
    // MARK: Getters
    
    private static var systemNotificationCenter: NotificationCenter {
        get { NotificationCenter.default }
    }
    
    // Reconnects and refreshes the data
    // Called because the websocket may have disconnected or
    // new data may have been sent when the user closed their app
    internal func linkInbox() async {
        await inboxModule.getInbox(isRefresh: true)
    }

    // Disconnects the websocket
    // Helps keep battery usage lower
    internal func unlinkInbox() async {
        await inboxModule.dataService.stop()
    }
    
    public func refreshInbox() async {
        await inboxModule.getInbox(isRefresh: true)
    }
    
    func restartInbox() async {
        await inboxModule.getInbox(isRefresh: false)
    }
    
    func closeInbox() async {
        await inboxModule.dataService.stop()
    }
    
    @discardableResult
    public func fetchNextInboxPage(_ feed: InboxMessageFeed) async throws -> InboxMessageDataSet? {
        return try await inboxModule.getNextPage(feedType: feed)
    }
    
    // MARK: Listeners
    
    @discardableResult
    public func addInboxListener(
        onLoading: ((_ isRefresh: Bool) -> Void)? = nil,
        onError: ((_ error: Error) -> Void)? = nil,
        onUnreadCountChanged: ((_ unreadCount: Int) -> Void)? = nil,
        onTotalCountChanged: ((_ totalCount: Int, _ feed: InboxMessageFeed) -> Void)? = nil,
        onMessagesChanged: ((_ message: [InboxMessage], _ canPaginate: Bool, _ feed: InboxMessageFeed) -> Void)? = nil,
        onMessageEvent: ((_ message: InboxMessage, _ index: Int, _ feed: InboxMessageFeed, _ event: InboxMessageEvent) -> Void)? = nil
    ) async -> NewCourierInboxListener {
        
        let listener = NewCourierInboxListener(
            onLoading: onLoading,
            onError: onError,
            onUnreadCountChanged: onUnreadCountChanged,
            onTotalCountChanged: onTotalCountChanged,
            onMessagesChanged: onMessagesChanged,
            onMessageEvent: onMessageEvent
        )
        
        await listener.initialize()
        
        // Register listener
        inboxModule.addListener(listener)
        
        // Ensure the user is signed in
        if !isUserSignedIn {
            Logger.warn("User is not signed in. Please call Courier.shared.signIn(...) to setup the inbox listener.")
            await listener.error(CourierError.userNotFound)
            return listener
        }
        
        switch inboxModule.state {
        case .uninitialized:
            // Get the inbox data
            // If an existing call is going out, it will cancel that call.
            // This will return data for the last inbox listener that is registered
            await inboxModule.getInbox(isRefresh: false)
        case .fetching:
            // Do not hit any callbacks while data is fetching
            break
        case .initialized:
            await listener.onLoad(inboxModule.dataStore.getSnapshot())
        }
        
        return listener
        
    }
    
    public func removeInboxListener(_ listener: NewCourierInboxListener) async {
        
        inboxModule.removeListener(listener)
        
        if inboxModule.inboxListeners.isEmpty {
            await closeInbox()
        }
        
    }
    
    public func removeAllInboxListeners() async {
        await inboxModule.removeAllListeners()
    }
    
    public func clickMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
//        try await inboxModule.data?.updateMessage(
//            messageId: messageId,
//            event: .click,
//            client: client,
//            handler: handler
//        )
        
    }
    
    public func readMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        let message = InboxMessage(messageId: messageId)
        await inboxModule.dataStore.readMessage(message, from: .feed, client: client)
        await inboxModule.dataStore.readMessage(message, from: .archived, client: client)

    }
    
    public func unreadMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        let message = InboxMessage(messageId: messageId)
        await inboxModule.dataStore.unreadMessage(message, from: .feed, client: client)
        await inboxModule.dataStore.unreadMessage(message, from: .archived, client: client)

    }
    
    public func archiveMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        let message = InboxMessage(messageId: messageId)
        await inboxModule.dataStore.archiveMessage(message, from: .feed, client: client)
        await inboxModule.dataStore.archiveMessage(message, from: .archived, client: client)

    }
    
    public func openMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        let message = InboxMessage(messageId: messageId)
        await inboxModule.dataStore.openMessage(message, from: .feed, client: client)
        await inboxModule.dataStore.openMessage(message, from: .archived, client: client)

    }
    
    public func readAllInboxMessages() async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        await inboxModule.dataStore.readAllMessages(client: client)

    }
    
}
