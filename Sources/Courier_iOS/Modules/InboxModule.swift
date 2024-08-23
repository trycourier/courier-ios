//
//  CoreInbox.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import UIKit

internal protocol InboxModuleDelegate: AnyObject {
    func onInboxRestarted()
    func onInboxUpdated(inbox: Inbox)
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
    private(set) var inbox: Inbox? = nil
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
                self.inbox = updatedInbox
                delegate?.onInboxUpdated(inbox: updatedInbox)
                
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
            self.inbox = updatedInbox
            delegate?.onInboxUpdated(inbox: updatedInbox)
            
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
        let messageCount = inbox?.messages?.count ?? Courier.shared.paginationLimit
        let maxRefreshLimit = min(messageCount, InboxModule.Pagination.max.rawValue)
        return refresh ? maxRefreshLimit : Courier.shared.paginationLimit
    }
    
    private func loadInbox(_ refresh: Bool) async throws -> Inbox {
        
        if !Courier.shared.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        guard let client = self.client else {
            throw CourierError.inboxNotInitialized
        }
        
        let limit = getPaginationLimit(refresh: refresh)
        
        async let dataTask: (InboxResponse) = client.inbox.getMessages(
            paginationLimit: limit,
            startCursor: nil
        )
        
        async let unreadCountTask: (Int) = client.inbox.getUnreadMessageCount()
        
        let (inboxResponse, unreadCount) = await (try dataTask, try unreadCountTask)
        
        // Connect the inbox socket
        try await connectWebSocket(client: client)
        
        let inboxData = inboxResponse.data
        
        return Inbox(
            messages: inboxData?.messages?.nodes,
            totalCount: inboxData?.count ?? 0,
            unreadCount: unreadCount,
            hasNextPage: inboxData?.messages?.pageInfo?.hasNextPage,
            startCursor: inboxData?.messages?.pageInfo?.startCursor
        )
        
    }
    
    private func connectWebSocket(client: CourierClient) async throws {
        
        self.socket?.disconnect()
        
        // Create the socket
        self.socket = InboxSocket(options: client.options)
        
        // Listen to the events
        self.socket?.receivedMessage = { message in
            
            Task { [weak self] in
                await self?.inbox?.addNewMessage(message: message)
                await self?.notifyInboxUpdated()
            }
            
        }
        
        self.socket?.receivedMessageEvent = { messageEvent in
            
            Task { [weak self] in
                
                switch (messageEvent.event) {
                case .markAllRead:
                    
                    await self?.inbox?.readAllMessages()
                    await self?.notifyInboxUpdated()
                    
                case .read:
                    
                    if let messageId = messageEvent.messageId {
                        try await self?.inbox?.readMessage(messageId: messageId)
                        await self?.notifyInboxUpdated()
                    }
                    
                case .unread:
                    
                    if let messageId = messageEvent.messageId {
                        try await self?.inbox?.unreadMessage(messageId: messageId)
                        await self?.notifyInboxUpdated()
                    }
                    
                case .archive:
                    
                    if let messageId = messageEvent.messageId {
                        try await self?.inbox?.openMessage(messageId: messageId)
                        await self?.notifyInboxUpdated()
                    }
                    
                case .opened:
                    
                    if let messageId = messageEvent.messageId {
                        try await self?.inbox?.openMessage(messageId: messageId)
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
    
    private func notifyInboxUpdated() {
        if let inbox = self.inbox {
            delegate?.onInboxUpdated(inbox: inbox)
        }
    }
    
    func fetchNextPage() async throws -> [InboxMessage] {
        
        if !Courier.shared.isUserSignedIn {
            throw CourierError.userNotFound
        }
        
        if self.inbox == nil {
            return []
        }

        let nextPage = inbox?.hasNextPage

        if (isPaging || nextPage == false) {
            return []
        }

        self.isPaging = true
        
        guard let inbox = self.inbox else {
            throw CourierError.inboxNotInitialized
        }
        
        guard let client = self.client else {
            throw CourierError.inboxNotInitialized
        }
        
        self.isPaging = true
        
        let res = try await client.inbox.getMessages(
            paginationLimit: Courier.shared.paginationLimit,
            startCursor: inbox.startCursor
        )
        
        let inboxData = res.data
        let newMessages = inboxData?.messages?.nodes ?? []
        let hasNextPage = inboxData?.messages?.pageInfo?.hasNextPage
        let startCursor = inboxData?.messages?.pageInfo?.startCursor

        inbox.addPage(
            newMessages: newMessages,
            startCursor: startCursor,
            hasNextPage: hasNextPage
        )
        
        // Update the local inbox
        self.inbox = inbox
        self.isPaging = false
        
        delegate?.onInboxUpdated(inbox: inbox)
        
        return inbox.messages ?? []
        
    }
    
    func updateMessage(messageId: String, event: InboxEventType) async throws {
        
        var original: UpdateOperation?
        
        // Handle the click action separately
        if event == .click {
            if let message = inbox?.messages?.first(where: { $0.messageId == messageId }),
               let channelId = message.trackingIds?.clickTrackingId {
                try await client?.inbox.click(messageId: messageId, trackingId: channelId)
            }
            return
        }
        
        // Perform other actions
        switch event {
        case .read:
            original = try inbox?.readMessage(messageId: messageId)
        case .unread:
            original = try inbox?.unreadMessage(messageId: messageId)
        case .opened:
            original = try inbox?.openMessage(messageId: messageId)
        case .unopened:
            original = try inbox?.unopenMessage(messageId: messageId)
        case .archive:
            original = try inbox?.archiveMessage(messageId: messageId)
        case .unarchive:
            original = try inbox?.unarchiveMessage(messageId: messageId)
        default:
            return
        }
        
        // Ensure there is an original message
        guard let og = original else {
            return
        }
        
        notifyInboxUpdated()
        
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
            inbox?.resetUpdate(update: og)
            notifyInboxUpdated()
            delegate?.onInboxError(with: error)
            
        }
    }
    
    func readAllMessages() async throws {

        let original = inbox?.readAllMessages()

        notifyInboxUpdated()

        do {
            
            try await client?.inbox.readAll()

        } catch {

            if let og = original {
                self.inbox?.resetReadAll(update: og)
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
    
    func onInboxUpdated(inbox: Inbox) {
        Task { @MainActor [weak self] in
            self?.inboxListeners.forEach({ listener in
                listener.onInboxUpdated(inbox)
            })
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
            return await inboxModule.inbox?.messages ?? []
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
    public func fetchNextInboxPage() async throws -> [InboxMessage] {
        return try await inboxModule.fetchNextPage()
    }
    
    // MARK: Listeners
    
    @discardableResult
    public func addInboxListener(
        onInitialLoad: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onMessagesChanged: ((_ messages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)? = nil
    ) -> CourierInboxListener {
        
        let newListener = CourierInboxListener(
            onInitialLoad: onInitialLoad,
            onError: onError,
            onMessagesChanged: onMessagesChanged
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
            if let inbox = await self.inboxModule.inbox {
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

internal class Inbox {
    
    var messages: [InboxMessage]?
    var totalCount: Int
    var unreadCount: Int
    var hasNextPage: Bool?
    var startCursor: String?
    
    init(messages: [InboxMessage]?, totalCount: Int, unreadCount: Int, hasNextPage: Bool?, startCursor: String?) {
        self.messages = messages
        self.totalCount = totalCount
        self.unreadCount = unreadCount
        self.hasNextPage = hasNextPage
        self.startCursor = startCursor
    }
    
    func addNewMessage(message: InboxMessage) {
        self.messages?.insert(message, at: 0)
        self.totalCount += 1
        self.unreadCount += 1
    }
    
    func addPage(newMessages: [InboxMessage], startCursor: String?, hasNextPage: Bool?) {
        self.messages?.append(contentsOf: newMessages)
        self.startCursor = startCursor
        self.hasNextPage = hasNextPage
    }
    
    @discardableResult func readAllMessages() -> ReadAllOperation {
        
        guard let messages = self.messages else {
            return ReadAllOperation(
                messages: [],
                unreadCount: 0
            )
        }
        
        // Copy previous values
        let originalMessages = Array(messages)
        let originalUnreadCount = self.unreadCount
        
        // Read all messages
        self.messages?.forEach { $0.setRead() }
        self.unreadCount = 0

        return ReadAllOperation(
            messages: originalMessages,
            unreadCount: originalUnreadCount
        )
        
    }
    
    internal func resetReadAll(update: ReadAllOperation) {
        self.messages = update.messages
        self.unreadCount = update.unreadCount
    }
    
    @discardableResult private func updateMessage(messageId: String, event: InboxEventType) throws -> UpdateOperation? {
        
        guard let messages = self.messages else {
            return nil
        }
        
        let index = messages.firstIndex { $0.messageId == messageId }
        guard let i = index else {
            return nil
        }

        // Save copy
        let message = messages[i]
        let originalMessage = message.copy()
        let originalUnreadCount = self.unreadCount

        // Update based on action
        switch event {
        case .read:
            
            if message.isRead {
                return nil
            }
            
            message.setRead()
            self.unreadCount -= 1
            
        case .unread:
            
            if !message.isRead {
                return nil
            }
            
            message.setUnread()
            self.unreadCount += 1
            
        case .opened:
            
            if message.isOpened {
                return nil
            }
            
            message.setOpened()
            
        case .unopened:
            
            if !message.isOpened {
                return nil
            }
            
            message.setUnopened()
            
        case .archive:
            
            if message.isArchived {
                return nil
            }
            
            message.setArchived()
            
        case .unarchive:
            
            if !message.isArchived {
                return nil
            }
            
            message.setUnarchived()
            
        case .click:
            
            break
            
        case .unclick:
            
            break
            
        case .markAllRead:
            
            break
            
        }

        // Ensure unreadCount doesn't go below zero
        self.unreadCount = max(self.unreadCount, 0)
        
        // Change data
        self.messages?[i] = message

        return UpdateOperation(
            index: i,
            unreadCount: originalUnreadCount,
            message: originalMessage
        )
    }
    
    func resetUpdate(update: UpdateOperation) {
        self.messages?[update.index] = update.message
        self.unreadCount = update.unreadCount
    }
    
    @discardableResult func readMessage(messageId: String) throws -> UpdateOperation? {
        return try updateMessage(messageId: messageId, event: .read)
    }
    
    @discardableResult func unreadMessage(messageId: String) throws -> UpdateOperation? {
        return try updateMessage(messageId: messageId, event: .unread)
    }
    
    @discardableResult func openMessage(messageId: String) throws -> UpdateOperation? {
        return try updateMessage(messageId: messageId, event: .opened)
    }
    
    @discardableResult func unopenMessage(messageId: String) throws -> UpdateOperation? {
        return try updateMessage(messageId: messageId, event: .unopened)
    }
    
    @discardableResult func archiveMessage(messageId: String) throws -> UpdateOperation? {
        return try updateMessage(messageId: messageId, event: .archive)
    }
    
    @discardableResult func unarchiveMessage(messageId: String) throws -> UpdateOperation? {
        return try updateMessage(messageId: messageId, event: .unarchive)
    }
    
}

internal struct ReadAllOperation {
    let messages: [InboxMessage]?
    let unreadCount: Int
}

internal struct UpdateOperation {
    let index: Int
    let unreadCount: Int
    let message: InboxMessage
}
