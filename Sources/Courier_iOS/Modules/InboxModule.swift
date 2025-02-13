//
//  CoreInbox.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import UIKit

@CourierActor internal class InboxModule {
    
    internal var inboxListeners: [CourierInboxListener] = []
    
    var data: CourierInboxData? = nil
    let repo = InboxRepository()
    
    func updateData(data: CourierInboxData?) {
        self.data = data
    }
    
    internal func addListener(_ listener: CourierInboxListener) {
        self.inboxListeners.append(listener)
        Courier.shared.client?.log("Courier Inbox Listener Registered. Total Listeners: \(self.inboxListeners.count)")
    }
    
    internal func removeListener(_ listener: CourierInboxListener) {
        self.inboxListeners.removeAll(where: { return $0 == listener })
        Courier.shared.client?.log("Courier Inbox Listener Unregistered. Total Listeners: \(self.inboxListeners.count)")
    }
    
    internal func removeAllListeners() {
        self.inboxListeners.removeAll()
        Courier.shared.client?.log("Courier Inbox Listeners Removed. Total Listeners: \(self.inboxListeners.count)")
    }
    
}

@CourierActor extension Courier: InboxMutationHandler {
    
    func onInboxItemAdded(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async {
        
        inboxModule.data?.addMessage(at: index, in: feed, with: message)
        
        let listeners = self.inboxModule.inboxListeners
        
        await MainActor.run {
            listeners.forEach { listener in
                listener.onMessageAdded?(feed, index, message)
            }
        }
        
    }
    
    func onInboxItemRemove(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async {
        
        let listeners = self.inboxModule.inboxListeners
        
        await MainActor.run {
            listeners.forEach { listener in
                listener.onMessageRemoved?(feed, index, message)
            }
        }
        
    }
    
    func onInboxItemUpdated(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async {
        
        inboxModule.data?.updateMessage(at: index, in: feed, with: message)
        
        let listeners = self.inboxModule.inboxListeners
        
        await MainActor.run {
            listeners.forEach { listener in
                listener.onMessageChanged?(feed, index, message)
            }
        }
        
    }
    
    func onInboxUpdated(inbox: CourierInboxData) async {
        
        inboxModule.updateData(data: inbox)
        
        if let data = inboxModule.data {
            
            let listeners = self.inboxModule.inboxListeners
            
            listeners.forEach { listener in
                Task {
                    await listener.onLoad(data: data)
                }
            }
            
        }
        
    }
    
    func onUnreadCountChange(count: Int) async {
        
        inboxModule.data?.updateUnreadCount(count: count)
        
        if let unreadCount = inboxModule.data?.unreadCount {
            
            let listeners = self.inboxModule.inboxListeners
            
            await MainActor.run {
                listeners.forEach { listener in
                    listener.onUnreadCountChanged?(unreadCount)
                }
            }
            
        }
        
    }
    
    func onInboxReset(inbox: CourierInboxData, error: any Error) async {
        
        inboxModule.updateData(data: inbox)
        
        if let data = inboxModule.data {
            
            let listeners = self.inboxModule.inboxListeners
                
            listeners.forEach { listener in
                Task {
                    await listener.onLoad(data: data)
                }
            }
            
        }
        
    }
    
    func onInboxReload(isRefresh: Bool) async {
        
        let listeners = self.inboxModule.inboxListeners
        
        await MainActor.run {
            listeners.forEach({ listener in
                listener.onLoading?(isRefresh)
            })
        }
        
    }
    
    func onInboxError(with error: any Error) async {
        
        await onUnreadCountChange(count: 0)
        
        let listeners = self.inboxModule.inboxListeners
        
        await MainActor.run {
            listeners.forEach({ listener in
                listener.onError?(error)
            })
        }
        
    }
    
    func onInboxPageFetched(feed: InboxMessageFeed, messageSet: InboxMessageSet) async {
        
        // Add the page
        inboxModule.data?.addPage(in: feed, with: messageSet)
        
        let listeners = self.inboxModule.inboxListeners
        
        // Call the listeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onPageAdded?(feed, messageSet)
            }
        }
        
    }
    
    func onInboxMessageReceived(message: InboxMessage) async {
        
        let index = 0
        let feed: InboxMessageFeed = message.isArchived ? .archived : .feed
        inboxModule.data?.addMessage(at: index, in: feed, with: message)
        
        if let data = inboxModule.data {
            
            let listeners = self.inboxModule.inboxListeners
            let unreadCount = data.unreadCount
            
            await MainActor.run {
                listeners.forEach { listener in
                    listener.onMessageAdded?(feed, index, message)
                    listener.onUnreadCountChanged?(unreadCount)
                }
            }
            
        }
        
    }
    
    func onInboxEventReceived(event: InboxSocket.MessageEvent) async {
        do {
            switch event.event {
            case .markAllRead:
                try await Courier.shared.readAllInboxMessages()
            case .read:
                if let messageId = event.messageId {
                    try await Courier.shared.readMessage(messageId)
                }
            case .unread:
                if let messageId = event.messageId {
                    try await Courier.shared.unreadMessage(messageId)
                }
            case .opened:
                if let messageId = event.messageId {
                    try await Courier.shared.openMessage(messageId)
                }
            case .unopened:
                break
            case .archive:
                if let messageId = event.messageId {
                    try await Courier.shared.archiveMessage(messageId)
                }
            case .unarchive:
                break
            case .click:
                if let messageId = event.messageId {
                    try await Courier.shared.clickMessage(messageId)
                }
            case .unclick:
                break
            }
        } catch {
            Courier.shared.client?.log(error.localizedDescription)
        }
    }
    
    func onInboxKilled() async {
        client?.options.log("Courier Shared Inbox Killed")
    }
    
}

@CourierActor extension Courier {
    
    public var feedMessages: [InboxMessage] {
        get {
            return inboxModule.data?.feed.messages ?? []
        }
    }
    
    public var archivedMessages: [InboxMessage] {
        get {
            return inboxModule.data?.archived.messages ?? []
        }
    }
    
    public var inboxPaginationLimit: Int {
        get {
            return self.paginationLimit
        }
    }
    
    @objc public func setPaginationLimit(_ limit: Int) async {
        let min = min(InboxRepository.Pagination.max.rawValue, limit)
        self.paginationLimit = max(InboxRepository.Pagination.min.rawValue, min)
    }
    
    // MARK: Getters
    
    private static var systemNotificationCenter: NotificationCenter {
        get { NotificationCenter.default }
    }
    
    // Reconnects and refreshes the data
    // Called because the websocket may have disconnected or
    // new data may have been sent when the user closed their app
    internal func linkInbox() async {
        
        if self.inboxModule.inboxListeners.isEmpty {
            return
        }
        
        if !self.isUserSignedIn {
            return
        }
        
        guard let handler = self.inboxMutationHandler else {
            return
        }
        
        await inboxModule.repo.get(
            with: handler,
            feedMessageCount: inboxModule.data?.feed.messages.count,
            archiveMessageCount: inboxModule.data?.archived.messages.count,
            isRefresh: true
        )
        
    }

    // Disconnects the websocket
    // Helps keep battery usage lower
    internal func unlinkInbox() async {
        
        if self.inboxModule.inboxListeners.isEmpty {
            return
        }
        
        if !self.isUserSignedIn {
            return
        }
        
        guard let handler = self.inboxMutationHandler else {
            return
        }
        
        await inboxModule.repo.stop(with: handler)
        
    }
    
    public func refreshInbox() async {
        
        guard let handler = self.inboxMutationHandler else {
            return
        }
        
        await inboxModule.repo.get(
            with: handler,
            feedMessageCount: inboxModule.data?.feed.messages.count,
            archiveMessageCount: inboxModule.data?.archived.messages.count,
            isRefresh: true
        )
        
    }
    
    func restartInbox() async {
        
        guard let handler = self.inboxMutationHandler else {
            return
        }
        
        await inboxModule.repo.get(
            with: handler,
            feedMessageCount: inboxModule.data?.feed.messages.count,
            archiveMessageCount: inboxModule.data?.archived.messages.count,
            isRefresh: false
        )
        
    }
    
    func closeInbox() async {
        
        guard let handler = self.inboxMutationHandler else {
            return
        }
        
        await inboxModule.repo.stop(with: handler)
        await onInboxError(with: CourierError.userNotFound)
        
    }
    
    @discardableResult
    public func fetchNextInboxPage(_ feed: InboxMessageFeed) async throws -> InboxMessageSet? {
        
        guard let inboxData = inboxModule.data else {
            return nil
        }
        
        guard let messageSet = try await inboxModule.repo.getNextPage(feed, inboxData: inboxData) else {
            return nil
        }
        
        guard let handler = self.inboxMutationHandler else {
            return nil
        }
        
        await handler.onInboxPageFetched(feed: feed, messageSet: messageSet)
        
        return messageSet
        
    }
    
    // MARK: Listeners
    
    @discardableResult
    public func addInboxListener(
        onLoading: ((Bool) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onUnreadCountChanged: ((_ count: Int) -> Void)? = nil,
        onFeedChanged: ((_ messageSet: InboxMessageSet) -> Void)? = nil,
        onArchiveChanged: ((_ messageSet: InboxMessageSet) -> Void)? = nil,
        onPageAdded: ((_ feed: InboxMessageFeed, _ messageSet: InboxMessageSet) -> Void)? = nil,
        onMessageChanged: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)? = nil,
        onMessageAdded: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)? = nil,
        onMessageRemoved: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)? = nil
    ) async -> CourierInboxListener {
        
        let listener = CourierInboxListener(
            onLoading: onLoading,
            onError: onError,
            onUnreadCountChanged: onUnreadCountChanged,
            onFeedChanged: onFeedChanged,
            onArchiveChanged: onArchiveChanged,
            onPageAdded: onPageAdded,
            onMessageChanged: onMessageChanged,
            onMessageAdded: onMessageAdded,
            onMessageRemoved: onMessageRemoved
        )
        
        await listener.initialize()
        
        // Register listener
        inboxModule.addListener(listener)
        
        // Ensure the user is signed in
        if !isUserSignedIn {
            await MainActor.run {
                Logger.warn("User is not signed in. Please call Courier.shared.signIn(...) to setup the inbox listener.")
                listener.onError?(CourierError.userNotFound)
            }
            return listener
        }
        
        // Notify that data exists if needed
        if let data = inboxModule.data {
            await listener.onLoad(data: data)
            return listener
        }
        
        // Unwrap mutation handler
        guard let handler = self.inboxMutationHandler else {
            return listener
        }
        
        // Get the inbox data
        // If an existing call is going out, it will cancel that call.
        // This will return data for the last inbox listener that is registered
        await inboxModule.repo.get(
            with: handler,
            feedMessageCount: inboxModule.data?.feed.messages.count,
            archiveMessageCount: inboxModule.data?.archived.messages.count,
            isRefresh: false
        )
        
        return listener
        
    }
    
    public func removeInboxListener(_ listener: CourierInboxListener) async {
        
        inboxModule.removeListener(listener)
        
        if inboxModule.inboxListeners.isEmpty {
            await closeInbox()
        }
        
    }
    
    public func removeAllInboxListeners() {
        
        Task {
            
            inboxModule.removeAllListeners()
            
            if inboxModule.inboxListeners.isEmpty {
                Task {
                    await closeInbox()
                }
            }
            
        }
        
    }
    
    public func clickMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let handler = self.inboxMutationHandler else {
            return
        }
        
        try await inboxModule.data?.updateMessage(
            messageId: messageId,
            event: .click,
            client: client,
            handler: handler
        )
        
    }
    
    public func readMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let handler = self.inboxMutationHandler else {
            return
        }
        
        try await inboxModule.data?.updateMessage(
            messageId: messageId,
            event: .read,
            client: client,
            handler: handler
        )

    }
    
    public func unreadMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let handler = self.inboxMutationHandler else {
            return
        }
        
        try await inboxModule.data?.updateMessage(
            messageId: messageId,
            event: .unread,
            client: client,
            handler: handler
        )

    }
    
    public func archiveMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let handler = self.inboxMutationHandler else {
            return
        }
        
        try await inboxModule.data?.updateMessage(
            messageId: messageId,
            event: .archive,
            client: client,
            handler: handler
        )

    }
    
    public func openMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let handler = self.inboxMutationHandler else {
            return
        }
        
        try await inboxModule.data?.updateMessage(
            messageId: messageId,
            event: .opened,
            client: client,
            handler: handler
        )

    }
    
    public func readAllInboxMessages() async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let handler = self.inboxMutationHandler else {
            return
        }
        
        try await inboxModule.data?.readAllMessages(
            client: client,
            handler: handler
        )

    }
    
}
