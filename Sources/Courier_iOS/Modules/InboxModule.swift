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
    
    private func load(refresh: Bool) {
        
        self.streamTask?.cancel()
        
        self.streamTask = Task {
            
            do {
                
                // Fetch the inbox and call the delegate
                let updatedInbox = try await loadInbox(refresh)
                self.inbox = updatedInbox
                delegate?.onInboxUpdated(inbox: updatedInbox)
                
            } catch {
                
                // Complete and call delegate
                delegate?.onInboxError(with: error)
                
            }
            
        }
        
    }
    
    func restart() {
        delegate?.onInboxRestarted()
        load(refresh: false)
    }
    
    func refresh() {
        
        // Prevent refresh
        if (inbox == nil) {
            delegate?.onInboxError(with: CourierError.inboxNotInitialized)
            return
        }
        
        load(refresh: true)
        
    }
    
    func cleanUp() {
        
        // Cancel the stream
        self.streamTask?.cancel()
        self.streamTask = nil
        
        // Remove the socket
        self.socket?.disconnect()
        self.socket = nil
        
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
        
        let limit = getPaginationLimit(refresh: refresh)
        
        guard let client = Courier.shared.client else {
            throw CourierError.inboxNotInitialized
        }
        
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
                
                // Add the new page of messages
                await self?.inbox?.addNewMessage(message: message)
                
                // Call delegate
                if let inbox = await self?.inbox {
                    await self?.delegate?.onInboxUpdated(inbox: inbox)
                }
                
            }
            
        }
        
        self.socket?.receivedMessageEvent = { messageEvent in
            
            Task { [weak self] in
                
                switch (messageEvent.event) {
                case .markAllRead:
                    
                    // Add the new page of messages
                    await self?.inbox?.readAllMessages()
                    
                    // Call delegate
                    if let inbox = await self?.inbox {
                        await self?.delegate?.onInboxUpdated(inbox: inbox)
                    }
                    
                case .read:
                    
                    if let messageId = messageEvent.messageId {
                        
                        // Read a message
                        try await self?.inbox?.readMessage(messageId: messageId)
                        
                        // Call delegate
                        if let inbox = await self?.inbox {
                            await self?.delegate?.onInboxUpdated(inbox: inbox)
                        }
                        
                    }
                    
                case .unread:
                    
                    if let messageId = messageEvent.messageId {
                        
                        // Unread a message
                        try await self?.inbox?.unreadMessage(messageId: messageId)
                        
                        // Call delegate
                        if let inbox = await self?.inbox {
                            await self?.delegate?.onInboxUpdated(inbox: inbox)
                        }
                        
                    }
                    
                case .archive:
                    
                    client.log("Message Archived")
                    
                case .opened:
                    
                    client.log("Message Opened")
                    
                }
                
            }
            
        }
        
        // Connect the socket
        try await self.socket?.connect()
        
        // Subscribe to the events
        try await self.socket?.sendSubscribe()
        
    }
    
    func fetchNextPage() async throws -> [InboxMessage] {
        
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
        
        guard let client = Courier.shared.client else {
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
    
    internal enum FetchType {
        case page
        case refresh
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
    
//    // Reconnects and refreshes the data
//    // Called because the websocket may have disconnected or
//    // new data may have been sent when the user closed their app
//    internal func link() {
//        
//        Task {
//            
//            let listeners = await inboxModule.listeners
//            
//            if (!listeners.isEmpty) {
//                
//                // Connect the socket if needed
//                try await inboxModule.socket?.connect()
//                
//                // Fetch all the latest data
//                do {
//                    try await loadInbox(refresh: true)
//                } catch {
//                    let e = CourierError(from: error)
//                    notifyError(e)
//                }
//                
//            }
//            
//        }
//        
//    }

//    // Disconnects the websocket
//    // Helps keep battery usage lower
//    internal func unlink() {
//        
//        if (!inboxModule.listeners.isEmpty) {
//            inboxModule.socket?.disconnect()
//        }
//        
//    }
    
    func refreshInbox() async {
        await inboxModule.refresh()
    }
    
    @discardableResult
    func fetchNextInboxPage() async throws -> [InboxMessage] {
        return try await inboxModule.fetchNextPage()
    }
    
    // MARK: Listeners
    
    func addInboxListener(
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
    
    func removeInboxListener(_ listener: CourierInboxListener) {
        
        self.inboxListeners.removeAll(where: { return $0 == listener })
        
        if (inboxListeners.isEmpty) {
            Task {
                await inboxModule.cleanUp()
            }
        }
        
    }
    
    func removeAllInboxListeners() {
        self.inboxListeners.removeAll()
    }
    
//    
//    internal func removeAllListeners() {
//        listeners.removeAll()
//        close()
//        notifyError(CourierError.userNotFound)
//    }
//    
//    internal func close() {
//        self.inbox = nil
//        self.socket?.disconnect()
//    }
    
//    internal func stop() {
//        self.close()
//        notifyError(CourierError.userNotFound)
//    }
    
//    internal func refresh() async throws {
//        try await loadInbox(refresh: true)
//    }
//    
//    internal func refresh(onComplete: @escaping () -> Void) {
//        Task {
//            do {
//                try await refresh()
//            } catch {
//                self.notifyError(error)
//            }
//            Utils.runOnMainThread {
//                onComplete()
//            }
//        }
//    }
    
    internal func clickMessage(messageId: String) async throws {
        
//        guard let userId = Courier.shared.userId else {
//            throw CourierError.userNotFound
//        }
//        
//        let messages = await inbox?.messages
//        
//        if let message = messages?.filter({ $0.messageId == messageId }).first, let channelId = message.trackingIds?.clickTrackingId {
//            
////            try await inboxRepo.clickMessage(
////                clientKey: Courier.shared.clientKey,
////                jwt: Courier.shared.jwt,
////                clientSourceId: connectionId,
////                userId: userId,
////                messageId: messageId,
////                channelId: channelId
////            )
//            
//        }
        
    }
    
    internal func readMessage(messageId: String) async throws {

//        guard let userId = Courier.shared.userId else {
//            throw CourierError.userNotFound
//        }
//
//        // Mark the message as read instantly
//        let original = try await self.inbox?.readMessage(messageId: messageId)
//
//        // Notify
//        await notifyMessagesChanged()
//
//        // Perform datasource change in background
//        do {
//            
////            try await inboxRepo.readMessage(
////                clientKey: Courier.shared.clientKey,
////                jwt: Courier.shared.jwt,
////                clientSourceId: connectionId,
////                userId: userId,
////                messageId: messageId
////            )
//            
//        } catch {
//            
//            if let og = original {
//                await self.inbox?.resetUpdate(update: og)
//            }
//            
//            await self.notifyMessagesChanged()
//            self.notifyError(error)
//            
//        }

    }
    
    internal func unreadMessage(messageId: String) async throws {

//        guard let userId = Courier.shared.userId else {
//            throw CourierError.userNotFound
//        }
//
//        // Mark the message as read instantly
//        let original = try await self.inbox?.unreadMessage(messageId: messageId)
//
//        // Notify
//        await notifyMessagesChanged()
//
//        // Perform datasource change in background
//        do {
//            
////            try await inboxRepo.unreadMessage(
////                clientKey: Courier.shared.clientKey,
////                jwt: Courier.shared.jwt,
////                clientSourceId: connectionId,
////                userId: userId,
////                messageId: messageId
////            )
//            
//        } catch {
//            
//            if let og = original {
//                await self.inbox?.resetUpdate(update: og)
//            }
//            
//            await self.notifyMessagesChanged()
//            self.notifyError(error)
//            
//        }

    }
    
    internal func readAllMessages() async throws {

//        guard let userId = Courier.shared.userId else {
//            throw CourierError.userNotFound
//        }
//
//        // Read the messages
//        let original = await self.inbox?.readAllMessages()
//
//        // Notify
//        await self.notifyMessagesChanged()
//
//        // Perform datasource change in background
//        do {
////            try await inboxRepo.readAllMessages(
////                clientKey: Courier.shared.clientKey,
////                jwt: Courier.shared.jwt,
////                clientSourceId: connectionId,
////                userId: userId
////            )
//        } catch {
//            
//            if let og = original {
//                await self.inbox?.resetReadAll(update: og)
//            }
//            
//            await self.notifyMessagesChanged()
//            self.notifyError(error)
//            
//        }

    }
    
}

extension Courier {
    
//    @objc public func getInboxMessages() async -> [InboxMessage]? {
//        return await coreInbox.inbox?.messages
//    }
//    
//    @objc public var inboxPaginationLimit: Int {
//        get {
//            return coreInbox.paginationLimit
//        }
//        set {
//            let min = min(CoreInbox.defaultMaxPaginationLimit, newValue)
//            coreInbox.paginationLimit = max(CoreInbox.defaultMinPaginationLimit, min)
//        }
//    }
//    
//    /**
//     Connects to the Courier Inbox service to handle new messages and other events that get sent to the device
//     Only one websocket connection and data fetching operation will get setup when calling this.
//     */
//    @discardableResult @objc public func addInboxListener(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onMessagesChanged: ((_ messages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)? = nil) -> CourierInboxListener {
//        return coreInbox.addInboxListener(onInitialLoad: onInitialLoad, onError: onError, onMessagesChanged: onMessagesChanged)
//    }
//    
//    @objc public func removeAllInboxListeners() {
//        coreInbox.removeAllListeners()
//    }
//    
//    /**
//     Grabs the next page of message from the inbox service
//     Will automatically prevent duplicate calls if a call is already performed
//     */
//    @discardableResult @objc public func fetchNextPageOfMessages() async throws -> [InboxMessage] {
//        return try await coreInbox.fetchNextPage()
//    }
//    
//    @objc public func fetchNextPageOfMessages(onSuccess: (([InboxMessage]) -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
//        Task {
//            do {
//                let newMessages = try await coreInbox.fetchNextPage()
//                Utils.runOnMainThread {
//                    onSuccess?(newMessages)
//                }
//            } catch {
//                let e = CourierError(from: error)
//                Courier.shared.client?.log(e.message)
//                Utils.runOnMainThread {
//                    onFailure?(e)
//                }
//            }
//        }
//    }
    
//    /**
//     Reloads and rebuilds the inbox with new messages and a new socket
//     Could be used for pull to refresh functionality
//     */
//    @objc public func refreshInbox() async throws {
//        try await coreInbox.refresh()
//    }
//    
//    @objc public func refreshInbox(onComplete: @escaping () -> Void) {
//        coreInbox.refresh(onComplete: onComplete)
//    }
//    
//    /**
//     Sets the message as `read`
//     */
//    @objc public func readMessage(messageId: String) async throws {
//        try await coreInbox.readMessage(messageId: messageId)
//    }
//    
//    @objc public func readMessage(messageId: String, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
//        Task {
//            do {
//                try await coreInbox.readMessage(messageId: messageId)
//                onSuccess?()
//            } catch {
//                let e = CourierError(from: error)
//                Courier.shared.client?.log(e.message)
//                onFailure?(e)
//            }
//        }
//    }
//    
//    /**
//     Sets the message as `unread`
//     */
//    @objc public func unreadMessage(messageId: String) async throws {
//        try await coreInbox.unreadMessage(messageId: messageId)
//    }
//    
//    @objc public func unreadMessage(messageId: String, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
//        Task {
//            do {
//                try await coreInbox.unreadMessage(messageId: messageId)
//                onSuccess?()
//            } catch {
//                let e = CourierError(from: error)
//                Courier.shared.client?.log(e.message)
//                onFailure?(e)
//            }
//        }
//    }
//    
//    /**
//     Sets the message as `clicked`
//     */
//    @objc public func clickMessage(messageId: String) async throws {
//        try await coreInbox.clickMessage(messageId: messageId)
//    }
//    
//    @objc public func clickMessage(messageId: String, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
//        Task {
//            do {
//                try await coreInbox.clickMessage(messageId: messageId)
//                onSuccess?()
//            } catch {
//                let e = CourierError(from: error)
//                Courier.shared.client?.log(e.message)
//                onFailure?(e)
//            }
//        }
//    }
//    
//    /**
//     Sets `read` on all messages
//     */
//    @objc public func readAllInboxMessages() async throws {
//        try await coreInbox.readAllMessages()
//    }
//    
//    @objc public func readAllInboxMessages(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
//        Task {
//            do {
//                try await coreInbox.readAllMessages()
//                onSuccess?()
//            } catch {
//                let e = CourierError(from: error)
//                Courier.shared.client?.log(e.message)
//                onFailure?(e)
//            }
//        }
//    }
    
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
    
    @discardableResult func readMessage(messageId: String) throws -> UpdateOperation? {
        
        guard let messages = self.messages else {
            return nil
        }
        
        let index = messages.firstIndex { $0.messageId == messageId }
        guard let i = index else {
            return nil
        }

        // Save copy
        let message = messages[i]
        let originalMessage = message.copy() as! InboxMessage
        let originalUnreadCount = self.unreadCount

        // Update
        message.setRead()

        // Change data
        self.messages?[i] = message
        self.unreadCount -= 1
        self.unreadCount = max(self.unreadCount, 0)

        return UpdateOperation(
            index: i,
            unreadCount: originalUnreadCount,
            message: originalMessage
        )
        
    }
    
    @discardableResult func unreadMessage(messageId: String) throws -> UpdateOperation? {
        
        guard let messages = self.messages else {
            return nil
        }
        
        let index = messages.firstIndex { $0.messageId == messageId }
        guard let i = index else {
            return nil
        }

        // Save copy
        let message = messages[i]
        let originalMessage = message.copy() as! InboxMessage
        let originalUnreadCount = self.unreadCount

        // Update
        message.setUnread()

        // Change data
        self.messages?[i] = message
        self.unreadCount += 1
        self.unreadCount = max(self.unreadCount, 0)

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
