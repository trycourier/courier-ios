//
//  CoreInbox.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import UIKit

internal protocol InboxMutationHandler {
    func onInboxReload(isRefresh: Bool) async
    func onInboxKilled() async
    func onInboxReset(inbox: CourierInboxData, error: Error) async
    func onInboxUpdated(inbox: CourierInboxData) async
    func onInboxItemAdded(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async
    func onInboxItemRemove(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async
    func onInboxItemUpdated(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async
    func onInboxPageFetched(feed: InboxMessageFeed, messageSet: InboxMessageSet) async
    func onInboxMessageReceived(message: InboxMessage) async
    func onInboxEventReceived(event: InboxSocket.MessageEvent) async
    func onInboxError(with error: Error) async
    func onUnreadCountChange(count: Int) async
}

internal enum InboxEventType: String, Codable {
    case markAllRead = "mark-all-read"
    case read = "read"
    case unread = "unread"
    case opened = "opened"
    case unopened = "unopened"
    case archive = "archive"
    case unarchive = "unarchive"
    case click = "click"
    case unclick = "unclick"
}

internal actor InboxModule {
    
    internal var inboxListeners: [CourierInboxListener] = []
    
    var data: CourierInboxData? = nil
    lazy var repo = InboxRepository()
    
    func updateData(data: CourierInboxData?) {
        self.data = data
    }
    
    internal func addListener(_ listener: CourierInboxListener) {
        inboxListeners.append(listener)
    }
    
    internal func removeListener(_ listener: CourierInboxListener) {
        inboxListeners.removeAll(where: { return $0 == listener })
    }
    
    internal func removeAllListeners() {
        inboxListeners.removeAll()
    }
    
}

extension Courier: InboxMutationHandler {
    
    func onInboxItemAdded(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async {
        
        await inboxModule.data?.addMessage(at: index, in: feed, with: message)
        
        let listeners = await self.inboxModule.inboxListeners
        
        DispatchQueue.main.async {
            listeners.forEach { listener in
                listener.onMessageAdded?(feed, index, message)
            }
        }
        
    }
    
    func onInboxItemRemove(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async {
        
        let listeners = await self.inboxModule.inboxListeners
        
        DispatchQueue.main.async {
            listeners.forEach { listener in
                listener.onMessageRemoved?(feed, index, message)
            }
        }
        
    }
    
    func onInboxItemUpdated(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async {
        
        await inboxModule.data?.updateMessage(at: index, in: feed, with: message)
        
        let listeners = await self.inboxModule.inboxListeners
        
        DispatchQueue.main.async {
            listeners.forEach { listener in
                listener.onMessageChanged?(feed, index, message)
            }
        }
        
    }
    
    func onInboxUpdated(inbox: CourierInboxData) async {
        
        await inboxModule.updateData(data: inbox)
        
        if let data = await inboxModule.data {
            
            let listeners = await self.inboxModule.inboxListeners
            
            DispatchQueue.main.async {
                listeners.forEach { listener in
                    listener.onLoad(data: data)
                }
            }
            
        }
        
    }
    
    func onUnreadCountChange(count: Int) async {
        
        await inboxModule.data?.updateUnreadCount(count: count)
        
        if let unreadCount = await inboxModule.data?.unreadCount {
            
            let listeners = await self.inboxModule.inboxListeners
            
            DispatchQueue.main.async {
                listeners.forEach { listener in
                    listener.onUnreadCountChanged?(unreadCount)
                }
            }
            
        }
        
    }
    
    func onInboxReset(inbox: CourierInboxData, error: any Error) async {
        
        await inboxModule.updateData(data: inbox)
        
        if let data = await inboxModule.data {
            
            let listeners = await self.inboxModule.inboxListeners
                
            DispatchQueue.main.async {
                listeners.forEach { listener in
                    listener.onLoad(data: data)
                }
            }
            
        }
        
    }
    
    func onInboxReload(isRefresh: Bool) async {
        
        if isRefresh {
            return
        }
        
        let listeners = await self.inboxModule.inboxListeners
        
        DispatchQueue.main.async {
            listeners.forEach({ listener in
                listener.onLoading?()
            })
        }
        
    }
    
    func onInboxKilled() async {
        client?.options.log("Courier Shared Inbox Killed")
    }
    
    func onInboxError(with error: any Error) async {
        
        await onUnreadCountChange(count: 0)
        
        let listeners = await self.inboxModule.inboxListeners
        
        DispatchQueue.main.async {
            listeners.forEach({ listener in
                listener.onError?(error)
            })
        }
        
    }
    
    func onInboxPageFetched(feed: InboxMessageFeed, messageSet: InboxMessageSet) async {
        
        // Add the page
        await inboxModule.data?.addPage(in: feed, with: messageSet)
        
        let listeners = await self.inboxModule.inboxListeners
        
        // Call the listeners
        DispatchQueue.main.async {
            listeners.forEach { listener in
                listener.onPageAdded?(feed, messageSet)
            }
        }
        
    }
    
    func onInboxMessageReceived(message: InboxMessage) async {
        
        let index = 0
        let feed: InboxMessageFeed = message.isArchived ? .archived : .feed
        await inboxModule.data?.addMessage(at: index, in: feed, with: message)
        
        if let data = await inboxModule.data {
            
            let listeners = await self.inboxModule.inboxListeners
            
            DispatchQueue.main.async {
                listeners.forEach { listener in
                    listener.onMessageAdded?(feed, index, message)
                    listener.onUnreadCountChanged?(data.unreadCount)
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
    
}

extension Courier {
    
    public var feedMessages: [InboxMessage] {
        get async {
            return await inboxModule.data?.feed.messages ?? []
        }
    }
    
    public var archivedMessages: [InboxMessage] {
        get async {
            return await inboxModule.data?.archived.messages ?? []
        }
    }
    
    public var inboxPaginationLimit: Int {
        get {
            return self.paginationLimit
        }
        set {
            let min = min(InboxRepository.Pagination.max.rawValue, newValue)
            self.paginationLimit = max(InboxRepository.Pagination.min.rawValue, min)
        }
    }
    
    // MARK: Getters
    
    private static var systemNotificationCenter: NotificationCenter {
        get { NotificationCenter.default }
    }
    
    // Reconnects and refreshes the data
    // Called because the websocket may have disconnected or
    // new data may have been sent when the user closed their app
    internal func linkInbox() async {
        
        if await self.inboxModule.inboxListeners.isEmpty {
            return
        }
        
        if !self.isUserSignedIn {
            return
        }
        
        await inboxModule.repo.get(
            with: inboxMutationHandler,
            inboxData: inboxModule.data,
            isRefresh: true
        )
        
    }

    // Disconnects the websocket
    // Helps keep battery usage lower
    internal func unlinkInbox() async {
        
        if await self.inboxModule.inboxListeners.isEmpty {
            return
        }
        
        if !self.isUserSignedIn {
            return
        }
        
        await inboxModule.repo.stop(with: inboxMutationHandler)
        
    }
    
    public func refreshInbox() async {
        await inboxModule.repo.get(
            with: inboxMutationHandler,
            inboxData: inboxModule.data,
            isRefresh: true
        )
    }
    
    func restartInbox() async {
        await inboxModule.repo.get(
            with: inboxMutationHandler,
            inboxData: inboxModule.data,
            isRefresh: false
        )
    }
    
    func closeInbox() async {
        await inboxModule.repo.stop(with: inboxMutationHandler)
        await onInboxError(with: CourierError.userNotFound)
    }
    
    @discardableResult
    public func fetchNextInboxPage(_ feed: InboxMessageFeed) async throws -> [InboxMessage] {
        
        guard let inboxData = await inboxModule.data else {
            return []
        }
        
        guard let messageSet = try await inboxModule.repo.getNextPage(feed, inboxData: inboxData) else {
            return []
        }
        
        await inboxMutationHandler.onInboxPageFetched(feed: feed, messageSet: messageSet)
        
        return messageSet.messages
        
    }
    
    // MARK: Listeners
    
    @discardableResult
    public func addInboxListener(
        onLoading: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onUnreadCountChanged: ((_ count: Int) -> Void)? = nil,
        onFeedChanged: ((_ messageSet: InboxMessageSet) -> Void)? = nil,
        onArchiveChanged: ((_ messageSet: InboxMessageSet) -> Void)? = nil,
        onPageAdded: ((_ feed: InboxMessageFeed, _ messageSet: InboxMessageSet) -> Void)? = nil,
        onMessageChanged: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)? = nil,
        onMessageAdded: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)? = nil,
        onMessageRemoved: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)? = nil
    ) -> CourierInboxListener {
        
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
        
        listener.initialize()
        
        Task { @MainActor in
            
            // Register listener
            await inboxModule.addListener(listener)
            
            // Ensure the user is signed in
            if !isUserSignedIn {
                Logger.warn("User is not signed in. Please call Courier.shared.signIn(...) to setup the inbox listener.")
                listener.onError?(CourierError.userNotFound)
                return
            }
            
            // Notify that data exists if needed
            if let data = await inboxModule.data {
                listener.onLoad(data: data)
                return
            }
            
            // Get the inbox data
            // If an existing call is going out, it will cancel that call.
            // This will return data for the last inbox listener that is registered
            await inboxModule.repo.get(
                with: inboxMutationHandler,
                inboxData: inboxModule.data,
                isRefresh: false
            )
            
        }
        
        return listener
        
    }
    
    public func removeInboxListener(_ listener: CourierInboxListener) {
        
        Task {
            
            await inboxModule.removeListener(listener)
            
            if await inboxModule.inboxListeners.isEmpty {
                Task {
                    await closeInbox()
                }
            }
            
        }
        
    }
    
    public func removeAllInboxListeners() {
        
        Task {
            
            await inboxModule.removeAllListeners()
            
            if await inboxModule.inboxListeners.isEmpty {
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
        
        try await inboxModule.data?.updateMessage(
            messageId: messageId,
            event: .click,
            client: client,
            handler: inboxMutationHandler
        )
        
    }
    
    public func readMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        try await inboxModule.data?.updateMessage(
            messageId: messageId,
            event: .read,
            client: client,
            handler: inboxMutationHandler
        )

    }
    
    public func unreadMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        try await inboxModule.data?.updateMessage(
            messageId: messageId,
            event: .unread,
            client: client,
            handler: inboxMutationHandler
        )

    }
    
    public func archiveMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        try await inboxModule.data?.updateMessage(
            messageId: messageId,
            event: .archive,
            client: client,
            handler: inboxMutationHandler
        )

    }
    
    public func openMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        try await inboxModule.data?.updateMessage(
            messageId: messageId,
            event: .opened,
            client: client,
            handler: inboxMutationHandler
        )

    }
    
    public func readAllInboxMessages() async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        try await inboxModule.data?.readAllMessages(
            client: client,
            handler: inboxMutationHandler
        )

    }
    
}
