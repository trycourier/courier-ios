//
//  CoreInbox.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import UIKit

internal protocol InboxDelegate: AnyObject {
    func onInboxReload(isRefresh: Bool) async
    func onInboxKilled() async
    func onInboxUpdated(inbox: CourierInboxData) async
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
    private(set) var data: CourierInboxData? = nil
    internal lazy var repo = InboxRepository()
    internal weak var delegate: InboxDelegate?
}

extension InboxModule: InboxDelegate {
    
    func onInboxReload(isRefresh: Bool) async {
        
        if isRefresh {
            return
        }
        
        Courier.shared.inboxListeners.forEach({ listener in
            listener.onInitialLoad?()
        })
        
    }
    
    func onInboxKilled() async {
        Courier.shared.client?.options.log("Courier Shared Inbox Killed")
    }
    
    func onInboxUpdated(inbox: CourierInboxData) async {
        Courier.shared.inboxListeners.forEach { listener in
            listener.onInboxUpdated(inbox)
        }
    }
    
    func onInboxMessageReceived(message: InboxMessage) async {
        
        let inboxFeed: InboxMessageFeed = message.isArchived ? .archived : .feed
        
    }
    
    func onInboxEventReceived(event: InboxSocket.MessageEvent) async {
        print("onInboxEventReceived")
    }
    
    func onInboxError(with error: any Error) async {
        Courier.shared.inboxListeners.forEach({ listener in
            listener.onError?(error)
        })
    }
    
}

//internal actor InboxModule {
//    
//    
//    internal let inboxRepo = InboxRepository()
//    
//    private(set) var data: CourierInboxData? = nil
//    
////    private var delegate: InboxModuleDelegate? {
////        get {
////            return Courier.shared.inboxDelegate
////        }
////    }
//    
////    func restart() async {
////        
////        // Tell listeners to restart
////        delegate?.onInboxRestarted()
////        
////        self.streamTask?.cancel()
////        
////        self.streamTask = Task {
////            
////            do {
////                
////                // Fetch the inbox and call the delegate
////                let updatedInbox = try await getInbox(false)
////                self.inboxData = updatedInbox
////                delegate?.onInboxUpdated(inbox: updatedInbox)
////                
////            } catch {
////                
////                // Complete and call delegate
////                delegate?.onInboxError(with: error)
////                
////            }
////            
////        }
////        
////    }
//    
////    func refresh() async {
////        
////        self.streamTask?.cancel()
////        
////        do {
////            
////            // Load the inbox and call the delegate
////            let updatedInbox = try await getInbox(true)
////            self.inboxData = updatedInbox
////            delegate?.onInboxUpdated(inbox: updatedInbox)
////            
////        } catch {
////            
////            // Complete and call delegate
////            delegate?.onInboxError(with: error)
////            
////        }
////        
////    }
//    
//    func cleanUp() {
//    
//        inboxRepo.stop()
//        
//        // Tell delegate
////        delegate?.onInboxError(
////            with: CourierError.userNotFound
////        )
//        
//    }
//    
//    internal func notifyInboxUpdated() {
////        if let inbox = self.data {
////            delegate?.onInboxUpdated(inbox: inbox)
////        }
//    }
//    
//    func getNextInboxPage(_ inboxFeed: InboxMessageFeed) async throws -> [InboxMessage] {
//        
////        if !Courier.shared.isUserSignedIn {
////            throw CourierError.userNotFound
////        }
////        
////        if self.inboxData == nil {
////            return []
////        }
////
////        let set = inboxFeed == .feed ? self.inboxData?.feed : self.inboxData?.archived
////        let nextPage = set?.canPaginate
////
////        if (isPaging || nextPage == false) {
////            return []
////        }
////
////        self.isPaging = true
////        
////        guard let inbox = self.inboxData else {
////            throw CourierError.inboxNotInitialized
////        }
////        
////        guard let client = self.client else {
////            throw CourierError.inboxNotInitialized
////        }
////        
////        self.isPaging = true
////        
////        let limit = getPaginationLimit()
////        
////        let res = inboxFeed == .feed ? try await client.inbox.getMessages(paginationLimit: limit, startCursor: set?.paginationCursor) : try await client.inbox.getArchivedMessages(paginationLimit: limit, startCursor: set?.paginationCursor)
////        
////        let messages = res.data?.messages
////        let newMessages = messages?.nodes ?? []
////        let hasNextPage = messages?.pageInfo?.hasNextPage
////        let startCursor = messages?.pageInfo?.startCursor
////
////        inbox.addPage(
////            inboxFeed,
////            newMessages: newMessages,
////            startCursor: startCursor,
////            hasNextPage: hasNextPage
////        )
////        
////        // Update the local inbox
////        self.inboxData = inbox
////        self.isPaging = false
////        
////        delegate?.onInboxUpdated(inbox: inbox)
////        
////        return inboxFeed == .feed ? inbox.feed.messages : inbox.archived.messages
//        
//        return []
//        
//    }
//    
//    func updateMessage(messageId: String, event: InboxEventType) async throws {
//        
////        var original: UpdateOperation?
////        
////        let feed: InboxMessageFeed = inboxData?.archived.messages.contains { $0.messageId == messageId } ?? false ? .archived : .feed
////        
////        // Handle the click action separately
////        if event == .click {
////            if feed == .archived {
////                if let message = inboxData?.archived.messages.first(where: { $0.messageId == messageId }),
////                let channelId = message.trackingIds?.clickTrackingId {
////                    try await client?.inbox.click(messageId: messageId, trackingId: channelId)
////                }
////            } else {
////                if let message = inboxData?.feed.messages.first(where: { $0.messageId == messageId }),
////                let channelId = message.trackingIds?.clickTrackingId {
////                    try await client?.inbox.click(messageId: messageId, trackingId: channelId)
////                }
////            }
////            return
////        }
////        
////        // Perform other actions
////        switch event {
////        case .read:
////            original = try inboxData?.readMessage(feed, messageId: messageId)
////        case .unread:
////            original = try inboxData?.unreadMessage(feed, messageId: messageId)
////        case .opened:
////            original = try inboxData?.openMessage(feed, messageId: messageId)
////        case .unopened:
////            original = try inboxData?.unopenMessage(feed, messageId: messageId)
////        case .archive:
////            original = try inboxData?.archiveMessage(feed, messageId: messageId)
////        case .unarchive:
////            original = try inboxData?.unarchiveMessage(feed, messageId: messageId)
////        default:
////            return
////        }
////        
////        // Ensure there is an original message
////        guard let og = original else {
////            return
////        }
////        
////        notifyInboxUpdated()
////        
////        do {
////            
////            switch event {
////            case .read:
////                try await client?.inbox.read(messageId: messageId)
////            case .unread:
////                try await client?.inbox.unread(messageId: messageId)
////            case .opened:
////                try await client?.inbox.open(messageId: messageId)
////            case .archive:
////                try await client?.inbox.archive(messageId: messageId)
////            default:
////                break
////            }
////            
////        } catch {
////            
////            // Reset the change
////            inboxData?.resetUpdate(feed, update: og)
////            notifyInboxUpdated()
////            delegate?.onInboxError(with: error)
////            
////        }
//    }
//    
//    func readAllMessages() async throws {
//
////        let original = inboxData?.readAllMessages(.feed)
////
////        notifyInboxUpdated()
////
////        do {
////            
////            try await client?.inbox.readAll()
////
////        } catch {
////
////            if let og = original {
////                self.inboxData?.resetReadAll(.feed, update: og)
////            }
////
////            notifyInboxUpdated()
////            delegate?.onInboxError(with: error)
////
////        }
//        
//    }
//    
//}

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
        
        await inboxModule.repo.get(isRefresh: true)
        
    }

    // Disconnects the websocket
    // Helps keep battery usage lower
    internal func unlinkInbox() async {
        
        if Courier.shared.inboxListeners.isEmpty {
            return
        }
        
        await inboxModule.repo.stop()
        
    }
    
    public func refreshInbox() async {
        await inboxModule.repo.get(isRefresh: true)
    }
    
    func restartInbox() async {
        await inboxModule.repo.get(isRefresh: false)
    }
    
    func closeInbox() async {
        await inboxModule.cleanUp()
    }
    
    @discardableResult
    public func fetchNextInboxPage(_ feed: InboxMessageFeed) async throws -> [InboxMessage] {
        return try await inboxModule.getNextInboxPage(feed)
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
            await inboxModule.repo.get(isRefresh: true)
            
        }
        
        return listener
        
    }
    
    public func removeInboxListener(_ listener: CourierInboxListener) {
        
        self.inboxListeners.removeAll(where: { return $0 == listener })
        
        if (inboxListeners.isEmpty) {
            Task {
                await inboxModule.cleanUp()
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
        
        try await self.inboxModule.updateMessage(
            messageId: messageId,
            event: .click
        )
        
    }
    
    public func readMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        try await inboxModule.updateMessage(
            messageId: messageId,
            event: .read
        )

    }
    
    public func unreadMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        try await inboxModule.updateMessage(
            messageId: messageId,
            event: .unread
        )

    }
    
    public func archiveMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        try await inboxModule.updateMessage(
            messageId: messageId,
            event: .archive
        )

    }
    
    public func openMessage(_ messageId: String) async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        try await inboxModule.updateMessage(
            messageId: messageId,
            event: .opened
        )

    }
    
    public func readAllInboxMessages() async throws {
        
        if !isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        try await inboxModule.readAllMessages()

    }
    
}
