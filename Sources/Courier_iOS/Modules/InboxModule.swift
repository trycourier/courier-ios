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
    func onInboxUpdated(inbox: CourierInboxData) async
    func onInboxItemAdded(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async
    func onInboxItemRemove(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async
    func onInboxItemUpdated(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async
    func onInboxPageFetched(feed: InboxMessageFeed, messageSet: InboxMessageSet) async
    func onInboxMessageReceived(message: InboxMessage) async
    func onInboxEventReceived(event: InboxSocket.MessageEvent) async
    func onInboxError(with error: Error) async
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
    
    var data: CourierInboxData? = nil
    lazy var repo = InboxRepository()
    
    func updateData(data: CourierInboxData?) {
        self.data = data
    }
    
    func updateMessage(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) {
        if feed == .feed {
            data?.feed.messages[index] = message
        } else {
            data?.archived.messages[index] = message
        }
    }
    
    func addMessage(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) {
        if feed == .feed {
            data?.feed.messages.insert(message, at: index)
        } else {
            data?.archived.messages.insert(message, at: index)
        }
    }
    
    func removeMessage(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) {
        if feed == .feed {
            data?.feed.messages.remove(at: index)
        } else {
            data?.archived.messages.remove(at: index)
        }
    }
    
    func addPage(in feed: InboxMessageFeed, with set: InboxMessageSet) {
        if feed == .feed {
            data?.feed.messages.append(contentsOf: set.messages)
            data?.feed.paginationCursor = set.paginationCursor
            data?.feed.canPaginate = set.canPaginate
        } else {
            data?.archived.messages.append(contentsOf: set.messages)
            data?.archived.paginationCursor = set.paginationCursor
            data?.archived.canPaginate = set.canPaginate
        }
    }
    
}

extension Courier: InboxMutationHandler {
    
    func onInboxItemAdded(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async {
        
        await inboxModule.addMessage(at: index, in: feed, with: message)
        
        if let data = await inboxModule.data {
            DispatchQueue.main.async {
                self.inboxListeners.forEach { listener in
                    listener.onInboxUpdated(data)
                }
            }
        }
        
    }
    
    func onInboxItemRemove(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async {
        
        await inboxModule.removeMessage(at: index, in: feed, with: message)
        
        if let data = await inboxModule.data {
            DispatchQueue.main.async {
                self.inboxListeners.forEach { listener in
                    listener.onInboxUpdated(data)
                }
            }
        }
        
    }
    
    func onInboxItemUpdated(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async {
        
        await inboxModule.updateMessage(at: index, in: feed, with: message)
        
        if let data = await inboxModule.data {
            DispatchQueue.main.async {
                self.inboxListeners.forEach { listener in
                    listener.onInboxUpdated(data)
                }
            }
        }
        
    }
    
    func onInboxReload(isRefresh: Bool) async {
        
        if isRefresh {
            return
        }
        
        DispatchQueue.main.async {
            self.inboxListeners.forEach({ listener in
                listener.onInitialLoad?()
            })
        }
        
    }
    
    func onInboxKilled() async {
        client?.options.log("Courier Shared Inbox Killed")
    }
    
    func onInboxUpdated(inbox: CourierInboxData) async {
        
        await inboxModule.updateData(data: inbox)
        
        if let data = await inboxModule.data {
            DispatchQueue.main.async {
                self.inboxListeners.forEach { listener in
                    listener.onInboxUpdated(data)
                }
            }
        }
        
    }
    
    func onInboxPageFetched(feed: InboxMessageFeed, messageSet: InboxMessageSet) async {
        
        // Add the page
        await inboxModule.addPage(in: feed, with: messageSet)
        
        // Call the listeners
        if let inbox = await inboxModule.data {
            await onInboxUpdated(inbox: inbox) // TODO
        }
        
    }
    
    func onInboxMessageReceived(message: InboxMessage) async {
        
        let feed: InboxMessageFeed = message.isArchived ? .archived : .feed
        await inboxModule.addMessage(at: 0, in: feed, with: message)
        
        if let data = await inboxModule.data {
            DispatchQueue.main.async {
                self.inboxListeners.forEach { listener in
                    listener.onInboxUpdated(data)
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
    
    func onInboxError(with error: any Error) async {
        DispatchQueue.main.async {
            self.inboxListeners.forEach({ listener in
                listener.onError?(error)
            })
        }
    }
    
}

extension Courier {
    
    public var inboxMessages: [InboxMessage] {
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
        
        if Courier.shared.inboxListeners.isEmpty {
            return
        }
        
        await inboxModule.repo.get(with: inboxMutationHandler, isRefresh: true)
        
    }

    // Disconnects the websocket
    // Helps keep battery usage lower
    internal func unlinkInbox() async {
        
        if Courier.shared.inboxListeners.isEmpty {
            return
        }
        
        await onInboxKilled()
        await inboxModule.repo.stop(with: inboxMutationHandler)
        
    }
    
    public func refreshInbox() async {
        await inboxModule.repo.get(with: inboxMutationHandler, isRefresh: true)
    }
    
    func restartInbox() async {
        await inboxModule.repo.get(with: inboxMutationHandler, isRefresh: false)
    }
    
    func closeInbox() async {
        await onInboxKilled()
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
        onInitialLoad: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onInboxChanged: ((_ inbox: CourierInboxData) -> Void)? = nil
    ) -> CourierInboxListener {
        
        let listener = CourierInboxListener(
            onInitialLoad: onInitialLoad,
            onError: onError,
            onInboxChanged: onInboxChanged
        )
        
        listener.initialize()
        
        Task { @MainActor in
            
            // Register listener
            Courier.shared.inboxListeners.append(listener)
            
            // Ensure the user is signed in
            if !isUserSignedIn {
                Logger.warn("User is not signed in. Please call Courier.shared.signIn(...) to setup the inbox listener.")
                listener.onError?(CourierError.userNotFound)
                return
            }
            
            // Notify that data exists if needed
            if let inbox = await inboxModule.data {
                listener.onInboxUpdated(inbox)
                return
            }
            
            // Get the inbox data
            // If an existing call is going out, it will cancel that call.
            // This will return data for the last inbox listener that is registered
            await inboxModule.repo.get(with: inboxMutationHandler, isRefresh: true)
            
        }
        
        return listener
        
    }
    
    public func removeInboxListener(_ listener: CourierInboxListener) {
        
        self.inboxListeners.removeAll(where: { return $0 == listener })
        
        if (inboxListeners.isEmpty) {
            Task {
                await closeInbox()
            }
        }
        
    }
    
    public func removeAllInboxListeners() {
        self.inboxListeners.removeAll()
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
