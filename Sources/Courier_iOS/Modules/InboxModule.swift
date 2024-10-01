//
//  CoreInbox.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import UIKit

internal protocol InboxModuleDelegate: AnyObject {
    func onInboxRestarted()
    func onInboxUpdated(inbox: CourierInboxData, ignoredListeners: [CourierInboxListener])
    func onInboxError(with error: Error)
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
    
    enum Pagination: Int {
        case `default` = 32
        case max = 100
        case min = 1
    }
    
    private(set) var isPaging = false
    private(set) var socket: InboxSocket? = nil
    private(set) var inboxData: CourierInboxData? = nil
    private(set) var streamTask: Task<Void, Never>? = nil
    
    private var delegate: InboxModuleDelegate? {
        get {
            return Courier.shared.inboxDelegate
        }
    }
    
    private var client: CourierClient? {
        get {
            return Courier.shared.client
        }
    }
    
    func restart() async {
        
        // Tell listeners to restart
        delegate?.onInboxRestarted()
        
        self.streamTask?.cancel()
        
        self.streamTask = Task {
            
            do {
                
                // Fetch the inbox and call the delegate
                let updatedInbox = try await loadInbox(false)
                self.inboxData = updatedInbox
                delegate?.onInboxUpdated(inbox: updatedInbox, ignoredListeners: [])
                
            } catch {
                
                // Complete and call delegate
                delegate?.onInboxError(with: error)
                
            }
            
        }
        
    }
    
    func refresh() async {
        
        self.streamTask?.cancel()
        
        do {
            
            // Load the inbox and call the delegate
            let updatedInbox = try await loadInbox(true)
            self.inboxData = updatedInbox
            delegate?.onInboxUpdated(inbox: updatedInbox, ignoredListeners: [])
            
        } catch {
            
            // Complete and call delegate
            delegate?.onInboxError(with: error)
            
        }
        
    }
    
    func cleanUp() {
        
        // Cancel the stream
        streamTask?.cancel()
        streamTask = nil
        
        // Remove the socket
        socket?.disconnect()
        socket = nil
        
        // Tell delegate
        delegate?.onInboxError(
            with: CourierError.userNotFound
        )
        
    }
    
    private func getPaginationLimit(refresh: Bool = false) -> Int {
        let messageCount = Courier.shared.paginationLimit
        let maxRefreshLimit = min(messageCount, InboxModule.Pagination.max.rawValue)
        return refresh ? maxRefreshLimit : Courier.shared.paginationLimit
    }
    
    private func loadInbox(_ refresh: Bool) async throws -> CourierInboxData {
        
        if !Courier.shared.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = self.client else {
            throw CourierError.inboxNotInitialized
        }
        
        let limit = getPaginationLimit(refresh: refresh)
        
        // Functions for getting data
        async let notificationsTask = client.inbox.getMessages(paginationLimit: limit, startCursor: nil)
        async let archivedTask = client.inbox.getArchivedMessages(paginationLimit: limit, startCursor: nil)
        async let unreadCountTask = client.inbox.getUnreadMessageCount()
        
        // Await all results at the same time
        let (notificationsResponse, archivedResponse, unreadCount) = await (try notificationsTask, try archivedTask, try unreadCountTask)
        
        // Connect the inbox socket
        try await connectWebSocket(client: client)
        
        return CourierInboxData(
            messages: notificationsResponse.toInboxMessageSet(),
            archived: archivedResponse.toInboxMessageSet(),
            unreadCount: unreadCount
        )
        
    }
    
    private func connectWebSocket(client: CourierClient) async throws {
        
        self.socket?.disconnect()
        
        // Create the socket
        self.socket = InboxSocketManager.getSocketInstance(
            options: client.options
        )
        
        // Listen to the events
        self.socket?.receivedMessage = { message in
            
            let inboxFeed: InboxMessageFeed = message.isArchived ? .archived : .feed
            
            Task { [weak self] in
                await self?.inboxData?.addNewMessage(inboxFeed, message: message)
                await self?.notifyInboxUpdated()
            }
            
        }
        
        self.socket?.receivedMessageEvent = { messageEvent in
            
            Task { [weak self] in
                
                switch (messageEvent.event) {
                case .markAllRead:
                    
                    await self?.inboxData?.readAllMessages(.feed)
                    await self?.notifyInboxUpdated()
                    
                case .read:
                    
                    if let messageId = messageEvent.messageId {
                        try await self?.inboxData?.readMessage(.feed, messageId: messageId)
                        await self?.notifyInboxUpdated()
                    }
                    
                case .unread:
                    
                    if let messageId = messageEvent.messageId {
                        try await self?.inboxData?.unreadMessage(.feed, messageId: messageId)
                        await self?.notifyInboxUpdated()
                    }
                    
                case .archive:
                    
                    if let messageId = messageEvent.messageId {
                        try await self?.inboxData?.archiveMessage(.feed, messageId: messageId)
                        await self?.notifyInboxUpdated()
                    }
                    
                case .opened:
                    
                    if let messageId = messageEvent.messageId {
                        try await self?.inboxData?.openMessage(.feed, messageId: messageId)
                        await self?.notifyInboxUpdated()
                    }
                    
                default:
                    break
                    
                }
                
            }
            
        }
        
        // Connect the socket
        try await self.socket?.connect()
        
        // Subscribe to the events
        try await self.socket?.sendSubscribe()
        
    }
    
    internal func notifyInboxUpdated(ignoredListeners: [CourierInboxListener] = []) {
        if let inbox = self.inboxData {
            delegate?.onInboxUpdated(inbox: inbox, ignoredListeners: ignoredListeners)
        }
    }
    
    func fetchNextPage(_ inboxFeed: InboxMessageFeed) async throws -> [InboxMessage] {
        
        if !Courier.shared.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        if self.inboxData == nil {
            return []
        }

        let set = inboxFeed == .feed ? self.inboxData?.feed : self.inboxData?.archived
        let nextPage = set?.canPaginate

        if (isPaging || nextPage == false) {
            return []
        }

        self.isPaging = true
        
        guard let inbox = self.inboxData else {
            throw CourierError.inboxNotInitialized
        }
        
        guard let client = self.client else {
            throw CourierError.inboxNotInitialized
        }
        
        self.isPaging = true
        
        let res = inboxFeed == .feed ? try await client.inbox.getMessages(paginationLimit: Courier.shared.paginationLimit, startCursor: set?.paginationCursor) : try await client.inbox.getArchivedMessages(paginationLimit: Courier.shared.paginationLimit, startCursor: set?.paginationCursor)
        
        let inboxData = res.data
        let newMessages = inboxData?.messages?.nodes ?? []
        let hasNextPage = inboxData?.messages?.pageInfo?.hasNextPage
        let startCursor = inboxData?.messages?.pageInfo?.startCursor

        inbox.addPage(
            inboxFeed,
            newMessages: newMessages,
            startCursor: startCursor,
            hasNextPage: hasNextPage
        )
        
        // Update the local inbox
        self.inboxData = inbox
        self.isPaging = false
        
        delegate?.onInboxUpdated(inbox: inbox, ignoredListeners: [])
        
        return inboxFeed == .feed ? inbox.feed.messages : inbox.archived.messages
        
    }
    
    func updateMessage(messageId: String, event: InboxEventType, ignoredListeners: [CourierInboxListener] = []) async throws {
        
        var original: UpdateOperation?
        
        let feed: InboxMessageFeed = inboxData?.archived.messages.contains { $0.messageId == messageId } ?? false ? .archived : .feed
        
        // Handle the click action separately
        if event == .click {
            if feed == .archived {
                if let message = inboxData?.archived.messages.first(where: { $0.messageId == messageId }),
                let channelId = message.trackingIds?.clickTrackingId {
                    try await client?.inbox.click(messageId: messageId, trackingId: channelId)
                }
            } else {
                if let message = inboxData?.feed.messages.first(where: { $0.messageId == messageId }),
                let channelId = message.trackingIds?.clickTrackingId {
                    try await client?.inbox.click(messageId: messageId, trackingId: channelId)
                }
            }
            return
        }
        
        // Perform other actions
        switch event {
        case .read:
            original = try inboxData?.readMessage(feed, messageId: messageId)
        case .unread:
            original = try inboxData?.unreadMessage(feed, messageId: messageId)
        case .opened:
            original = try inboxData?.openMessage(feed, messageId: messageId)
        case .unopened:
            original = try inboxData?.unopenMessage(feed, messageId: messageId)
        case .archive:
            original = try inboxData?.archiveMessage(feed, messageId: messageId)
        case .unarchive:
            original = try inboxData?.unarchiveMessage(feed, messageId: messageId)
        default:
            return
        }
        
        // Ensure there is an original message
        guard let og = original else {
            return
        }
        
        notifyInboxUpdated(ignoredListeners: ignoredListeners)
        
        do {
            
            switch event {
            case .read:
                try await client?.inbox.read(messageId: messageId)
            case .unread:
                try await client?.inbox.unread(messageId: messageId)
            case .opened:
                try await client?.inbox.open(messageId: messageId)
            case .archive:
                try await client?.inbox.archive(messageId: messageId)
            default:
                break
            }
            
        } catch {
            
            // Reset the change
            inboxData?.resetUpdate(feed, update: og)
            notifyInboxUpdated()
            delegate?.onInboxError(with: error)
            
        }
    }
    
    func readAllMessages() async throws {

        let original = inboxData?.readAllMessages(.feed)

        notifyInboxUpdated()

        do {
            
            try await client?.inbox.readAll()

        } catch {

            if let og = original {
                self.inboxData?.resetReadAll(.feed, update: og)
            }

            notifyInboxUpdated()
            delegate?.onInboxError(with: error)

        }
        
    }
    
}

extension Courier: InboxModuleDelegate {
    
    func onInboxRestarted() {
        Task { @MainActor [weak self] in
            self?.inboxListeners.forEach({ listener in
                listener.onInitialLoad?()
            })
        }
    }
    
    func onInboxUpdated(inbox: CourierInboxData, ignoredListeners: [CourierInboxListener]) {
        Task { @MainActor [weak self] in
            let filteredListeners = self?.inboxListeners.filter { !ignoredListeners.contains($0) }
            filteredListeners?.forEach { listener in
                listener.onInboxUpdated(inbox)
            }
        }
    }
    
    func onInboxError(with error: Error) {
        Task { @MainActor [weak self] in
            self?.inboxListeners.forEach({ listener in
                listener.onError?(error)
            })
        }
    }
    
}

extension Courier {
    
    public var inboxMessages: [InboxMessage] {
        get async {
            return await inboxModule.inboxData?.feed.messages ?? []
        }
    }
    
    public var archivedMessages: [InboxMessage] {
        get async {
            return await inboxModule.inboxData?.archived.messages ?? []
        }
    }
    
    public var inboxPaginationLimit: Int {
        get {
            return self.paginationLimit
        }
        set {
            let min = min(InboxModule.Pagination.max.rawValue, newValue)
            self.paginationLimit = max(InboxModule.Pagination.min.rawValue, min)
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
        
        if (inboxListeners.isEmpty) {
            return
        }
        
        await inboxModule.refresh()
        
    }

    // Disconnects the websocket
    // Helps keep battery usage lower
    internal func unlinkInbox() async {
        
        if (inboxListeners.isEmpty) {
            return
        }
        
        await inboxModule.socket?.disconnect()
        
    }
    
    public func refreshInbox() async {
        await inboxModule.refresh()
    }
    
    func restartInbox() async {
        await inboxModule.restart()
    }
    
    func closeInbox() async {
        await inboxModule.cleanUp()
    }
    
    @discardableResult
    public func fetchNextInboxPage(_ feed: InboxMessageFeed) async throws -> [InboxMessage] {
        return try await inboxModule.fetchNextPage(feed)
    }
    
    // MARK: Listeners
    
    @discardableResult
    public func addInboxListener(
        onInitialLoad: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onInboxChanged: ((_ inbox: CourierInboxData) -> Void)? = nil
    ) -> CourierInboxListener {
        
        let newListener = CourierInboxListener(
            onInitialLoad: onInitialLoad,
            onError: onError,
            onInboxChanged: onInboxChanged
        )
        
        Task { @MainActor in
            
            // Register listener
            inboxListeners.append(newListener)
            newListener.initialize()
            
            // Ensure the user is signed in
            if !isUserSignedIn {
                Logger.warn("User is not signed in. Please call Courier.shared.signIn(...) to setup the inbox listener.")
                newListener.onError?(CourierError.userNotFound)
                return
            }
            
            // Notify that data exists if needed
            if let inbox = await self.inboxModule.inboxData {
                newListener.onInboxUpdated(inbox)
                return
            }
            
            // Start the stream if needed
            if await inboxModule.streamTask == nil {
                await inboxModule.restart()
            }
            
        }
        
        return newListener
        
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
