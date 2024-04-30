//
//  CoreInbox.swift
//  
//
//  Created by https://github.com/mikemilla on 3/2/23.
//

import UIKit

internal class CoreInbox {
    
    internal enum FetchType {
        case page
        case refresh
    }
    
    private lazy var inboxRepo = InboxRepository()
    private lazy var brandsRepo = BrandsRepository()
    
    // MARK: Getters
    
    private static var systemNotificationCenter: NotificationCenter {
        get { NotificationCenter.default }
    }
    
    /**
     * Default pagination limit for messages
     */
    internal static let defaultPaginationLimit = 32
    internal static let defaultMaxPaginationLimit = 100
    internal static let defaultMinPaginationLimit = 1
    internal var paginationLimit = defaultPaginationLimit
    
    internal var inbox: Inbox? = nil

    private var listeners: [CourierInboxListener] = []
    
    private var fetchInboxData: Task<Void, Error>? = nil
    private var isPaging = false
    
    private func notifyInitialLoading() {
        Utils.runOnMainThread { [weak self] in
            self?.listeners.forEach {
                $0.initialize()
            }
        }
    }
    
    private func notifyError(_ error: Error) {
        Utils.runOnMainThread { [weak self] in
            self?.listeners.forEach {
                $0.onError?(error)
            }
        }
    }
    
    private func notifyMessagesChanged() async {
        
        let messages = await self.inbox?.messages
        let unreadCount = await self.inbox?.unreadCount
        let totalCount = await self.inbox?.totalCount
        let hasNextPage = await self.inbox?.hasNextPage
        
        Utils.runOnMainThread { [weak self] in
            self?.listeners.forEach {
                $0.callMessageChanged(
                    messages: messages,
                    unreadCount: unreadCount,
                    totalCount: totalCount,
                    hasNextPage: hasNextPage
                )
            }
        }
        
    }
    
    // Reconnects and refreshes the data
    // Called because the websocket may have disconnected or
    // new data may have been sent when the user closed their app
    internal func link() {
        
        Task {
            
            if (!listeners.isEmpty && CourierInboxWebsocket.shared?.isSocketConnected == false) {
                
                do {
                    try await start(refresh: true)
                } catch {
                    let e = CourierError(from: error)
                    notifyError(e)
                }
                
            }
            
        }
        
    }

    // Disconnects the websocket
    // Helps keep battery usage lower
    internal func unlink() {
        
        if (!listeners.isEmpty && CourierInboxWebsocket.shared?.isSocketConnected == true) {
            inboxRepo.closeInboxWebSocket()
        }
        
    }
    
    internal func start(refresh: Bool = false, onComplete: (() -> Void)? = nil) {
        
        // Get the current userId
        guard let userId = Courier.shared.userId else {
            stop()
            return
        }
        
        // Already fetching or fetched. End now
        if (self.fetchInboxData != nil || self.inbox != nil) {
            return
        }
        
        // Get auth keys
        let clientKey = Courier.shared.clientKey
        let jwt = Courier.shared.jwt
        
        // Keep track of the initial setup
        self.fetchInboxData = Task {
            
            // Initial load call
            if (!refresh) {
                notifyInitialLoading()
            }
            
            do {
                
                // Grab the initial inbox data
                let (inboxData, unreadCount) = try await self.fetchInitialInbox(
                    clientKey: clientKey,
                    jwt: jwt,
                    userId: userId,
                    refresh: refresh
                )
                
                // Connect the websocket
                try await self.connectWebSocket(
                    clientKey: clientKey,
                    userId: userId
                )
                
                // Set the inbox data
                self.inbox = Inbox(
                    messages: inboxData.messages?.nodes,
                    totalCount: inboxData.count ?? 0,
                    unreadCount: unreadCount,
                    hasNextPage: inboxData.messages?.pageInfo?.hasNextPage,
                    startCursor: inboxData.messages?.pageInfo?.startCursor
                )
        
                // Tell the listeners
                await notifyMessagesChanged()
                
            } catch {
                
                close()
                
                notifyError(error)
                
            }
            
            onComplete?()
            
        }
        
    }
    
    private func fetchInitialInbox(clientKey: String?, jwt: String?, userId: String, refresh: Bool) async throws -> (InboxData, Int) {
        
        let messageCount = await inbox?.messages?.count ?? paginationLimit
        let maxRefreshLimit = min(messageCount, CoreInbox.defaultMaxPaginationLimit)
        let limit = refresh ? maxRefreshLimit : paginationLimit

        async let dataTask: (InboxData) = inboxRepo.getMessages(
            clientKey: clientKey,
            jwt: jwt,
            userId: userId,
            paginationLimit: limit
        )

        async let unreadCountTask: (Int) = inboxRepo.getUnreadMessageCount(
            clientKey: clientKey,
            jwt: jwt,
            userId: userId
        )

        return await (try dataTask, try unreadCountTask)
        
    }
    
    private func connectWebSocket(clientKey: String?, userId: String) async throws {
        
        // Create a new socket
        try await inboxRepo.connectInboxWebSocket(
            clientKey: clientKey,
            userId: userId,
            onMessageReceived: { message in
                
                // Perform update with single reference
                Task { [weak self] in
                    await self?.inbox?.addNewMessage(message: message)
                    await self?.notifyMessagesChanged()
                }
                
            },
            onMessageReceivedError: { [weak self] error in
                
                // Catch the websocket disconnect error
                if (error.code == 57) {
                    return
                }
                
                self?.notifyError(error)
                
            }
        )
        
    }
    
    @discardableResult internal func fetchNextPageOfMessages() async throws -> [InboxMessage] {
        
        guard let userId = Courier.shared.userId, let inbox = self.inbox else {
            throw CourierError.missingUser
        }
        
        let inboxData = try await inboxRepo.getMessages(
            clientKey: Courier.shared.clientKey,
            jwt: Courier.shared.jwt,
            userId: userId,
            paginationLimit: paginationLimit,
            startCursor: inbox.startCursor
        )
        
        let newMessages = inboxData.messages?.nodes ?? []
        let hasNextPage = inboxData.messages?.pageInfo?.hasNextPage
        let startCursor = inboxData.messages?.pageInfo?.startCursor

        await self.inbox?.addPage(
            newMessages: newMessages,
            startCursor: startCursor,
            hasNextPage: hasNextPage
        )

        await self.notifyMessagesChanged()

        return newMessages
        
    }
    
    internal func addInboxListener(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onMessagesChanged: ((_ messages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)? = nil) -> CourierInboxListener {
        
        // Create a new inbox listener
        let listener = CourierInboxListener(
            onInitialLoad: onInitialLoad,
            onError: onError,
            onMessagesChanged: onMessagesChanged
        )
        
        // Keep track of listener
        listeners.append(listener)
        
        // Start the inbox data pipeline
        if (listeners.count == 1 && fetchInboxData == nil) {
            start()
            return listener
        }
        
        // Inbox data is available
        if let inbox = self.inbox {
            
            Task {

                // Return the existing inbox data
                let messages = await inbox.messages
                let unreadCount = await inbox.unreadCount
                let totalCount = await inbox.totalCount
                let hasNextPage = await inbox.hasNextPage

                // Give data to the listener
                Utils.runOnMainThread {
                    listener.callMessageChanged(
                        messages: messages,
                        unreadCount: unreadCount,
                        totalCount: totalCount,
                        hasNextPage: hasNextPage
                    )
                }

            }
            
        }
        
        return listener
        
    }
    
    internal func removeInboxListener(listener: CourierInboxListener) {
        
        // Look for the listener we need to remove
        listeners.removeAll(where: {
            return $0 == listener
        })
        
        // Kill the pipes if nothing is listening
        if (listeners.isEmpty) {
            stop()
            notifyError(CourierError.missingUser)
        }
        
    }
    
    internal func removeAllListeners() {
        listeners.removeAll()
        stop()
    }
    
    internal func close() {
        fetchInboxData?.cancel()
        fetchInboxData = nil
        inbox = nil
        inboxRepo.closeInboxWebSocket()
    }
    
    internal func stop() {
        close()
        notifyError(CourierError.missingUser)
    }
    
    internal func refresh(onComplete: @escaping () -> Void) {
        close()
        start(refresh: true) {
            Utils.runOnMainThread {
                onComplete()
            }
        }
    }
    
    @discardableResult internal func fetchNextPage() async throws -> [InboxMessage] {
        
        if self.inbox == nil {
            return []
        }
        
        var msgs: [InboxMessage] = []
        
        let hasNextPage = await inbox?.hasNextPage
        
        if (isPaging || hasNextPage == false) {
            return msgs
        }
        
        isPaging = true
        
        do {
            msgs = try await fetchNextPageOfMessages()
        } catch {
            self.notifyError(error)
        }
        
        isPaging = false
        
        return msgs
        
    }
    
    internal func clickMessage(messageId: String) async throws {
        
        guard let userId = Courier.shared.userId else {
            throw CourierError.missingUser
        }
        
        let messages = await inbox?.messages
        
        if let message = messages?.filter({ $0.messageId == messageId }).first, let channelId = message.trackingIds?.clickTrackingId {
            
            try await inboxRepo.clickMessage(
                clientKey: Courier.shared.clientKey,
                jwt: Courier.shared.jwt,
                userId: userId,
                messageId: messageId,
                channelId: channelId
            )
            
        }
        
    }
    
    internal func readMessage(messageId: String) async throws {

        guard let userId = Courier.shared.userId else {
            throw CourierError.missingUser
        }

        // Mark the message as read instantly
        let original = try await self.inbox?.readMessage(messageId: messageId)

        // Notify
        await notifyMessagesChanged()

        // Perform datasource change in background
        do {
            
            try await inboxRepo.readMessage(
                clientKey: Courier.shared.clientKey,
                jwt: Courier.shared.jwt,
                userId: userId,
                messageId: messageId
            )
            
        } catch {
            
            if let og = original {
                await self.inbox?.resetUpdate(update: og)
            }
            
            await self.notifyMessagesChanged()
            self.notifyError(error)
            
        }

    }
    
    internal func unreadMessage(messageId: String) async throws {

        guard let userId = Courier.shared.userId else {
            throw CourierError.missingUser
        }

        // Mark the message as read instantly
        let original = try await self.inbox?.unreadMessage(messageId: messageId)

        // Notify
        await notifyMessagesChanged()

        // Perform datasource change in background
        do {
            
            try await inboxRepo.unreadMessage(
                clientKey: Courier.shared.clientKey,
                jwt: Courier.shared.jwt,
                userId: userId,
                messageId: messageId
            )
            
        } catch {
            
            if let og = original {
                await self.inbox?.resetUpdate(update: og)
            }
            
            await self.notifyMessagesChanged()
            self.notifyError(error)
            
        }

    }
    
    internal func readAllMessages() async throws {

        guard let userId = Courier.shared.userId else {
            throw CourierError.missingUser
        }

        // Read the messages
        let original = await self.inbox?.readAllMessages()

        // Notify
        await self.notifyMessagesChanged()

        // Perform datasource change in background
        do {
            try await inboxRepo.readAllMessages(
                clientKey: Courier.shared.clientKey,
                jwt: Courier.shared.jwt,
                userId: userId
            )
        } catch {
            
            if let og = original {
                await self.inbox?.resetReadAll(update: og)
            }
            
            await self.notifyMessagesChanged()
            self.notifyError(error)
            
        }

    }
    
}

extension Courier {
    
    @objc public func getInboxMessages() async -> [InboxMessage]? {
        return await coreInbox.inbox?.messages
    }
    
    @objc public var inboxPaginationLimit: Int {
        get {
            return coreInbox.paginationLimit
        }
        set {
            let min = min(CoreInbox.defaultMaxPaginationLimit, newValue)
            coreInbox.paginationLimit = max(CoreInbox.defaultMinPaginationLimit, min)
        }
    }
    
    /**
     Connects to the Courier Inbox service to handle new messages and other events that get sent to the device
     Only one websocket connection and data fetching operation will get setup when calling this.
     */
    @discardableResult @objc public func addInboxListener(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onMessagesChanged: ((_ messages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)? = nil) -> CourierInboxListener {
        return coreInbox.addInboxListener(onInitialLoad: onInitialLoad, onError: onError, onMessagesChanged: onMessagesChanged)
    }
    
    @objc public func removeAllInboxListeners() {
        coreInbox.removeAllListeners()
    }
    
    /**
     Grabs the next page of message from the inbox service
     Will automatically prevent duplicate calls if a call is already performed
     */
    @discardableResult @objc public func fetchNextPageOfMessages() async throws -> [InboxMessage] {
        return try await coreInbox.fetchNextPage()
    }
    
    @objc public func fetchNextPageOfMessages(onSuccess: (([InboxMessage]) -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                let newMessages = try await coreInbox.fetchNextPage()
                Utils.runOnMainThread {
                    onSuccess?(newMessages)
                }
            } catch {
                let e = CourierError(from: error)
                Courier.log(e.message)
                Utils.runOnMainThread {
                    onFailure?(e)
                }
            }
        }
    }
    
    /**
     Reloads and rebuilds the inbox with new messages and a new socket
     Could be used for pull to refresh functionality
     */
    @objc public func refreshInbox() async throws {
        coreInbox.refresh {
            // Empty
        }
    }
    
    @objc public func refreshInbox(onComplete: @escaping () -> Void) {
        coreInbox.refresh(onComplete: onComplete)
    }
    
    /**
     Sets the message as `read`
     */
    @objc public func readMessage(messageId: String) async throws {
        try await coreInbox.readMessage(messageId: messageId)
    }
    
    @objc public func readMessage(messageId: String, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await coreInbox.readMessage(messageId: messageId)
                onSuccess?()
            } catch {
                let e = CourierError(from: error)
                Courier.log(e.message)
                onFailure?(e)
            }
        }
    }
    
    /**
     Sets the message as `unread`
     */
    @objc public func unreadMessage(messageId: String) async throws {
        try await coreInbox.unreadMessage(messageId: messageId)
    }
    
    @objc public func unreadMessage(messageId: String, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await coreInbox.unreadMessage(messageId: messageId)
                onSuccess?()
            } catch {
                let e = CourierError(from: error)
                Courier.log(e.message)
                onFailure?(e)
            }
        }
    }
    
    /**
     Sets the message as `clicked`
     */
    @objc public func clickMessage(messageId: String) async throws {
        try await coreInbox.clickMessage(messageId: messageId)
    }
    
    @objc public func clickMessage(messageId: String, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await coreInbox.clickMessage(messageId: messageId)
                onSuccess?()
            } catch {
                let e = CourierError(from: error)
                Courier.log(e.message)
                onFailure?(e)
            }
        }
    }
    
    /**
     Sets `read` on all messages
     */
    @objc public func readAllInboxMessages() async throws {
        try await coreInbox.readAllMessages()
    }
    
    @objc public func readAllInboxMessages(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await coreInbox.readAllMessages()
                onSuccess?()
            } catch {
                let e = CourierError(from: error)
                Courier.log(e.message)
                onFailure?(e)
            }
        }
    }
    
}

internal actor Inbox {
    
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
    
    func addNewMessage(message: InboxMessage) async {
        self.messages?.insert(message, at: 0)
        self.totalCount += 1
        self.unreadCount += 1
    }
    
    func addPage(newMessages: [InboxMessage], startCursor: String?, hasNextPage: Bool?) async {
        self.messages?.append(contentsOf: newMessages)
        self.startCursor = startCursor
        self.hasNextPage = hasNextPage
    }
    
    func readAllMessages() -> ReadAllOperation {
        
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
    
    func readMessage(messageId: String) throws -> UpdateOperation? {
        
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
    
    func unreadMessage(messageId: String) throws -> UpdateOperation? {
        
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
