//
//  CoreInbox.swift
//  
//
//  Created by Michael Miller on 3/2/23.
//

import UIKit

internal class CoreInbox {
    
    internal enum FetchType {
        case page
        case refresh
    }
    
    private lazy var inboxRepo = InboxRepository()
    
    // MARK: Getters
    
    private static var systemNotificationCenter: NotificationCenter {
        get { NotificationCenter.default }
    }
    
    /**
     * Default pagination limit for messages
     */
    internal static let defaultPaginationLimit = 24
    internal static let defaultMaxPaginationLimit = 200
    internal static let defaultMinPaginationLimit = 1
    internal var paginationLimit = defaultPaginationLimit

    private var listeners: [CourierInboxListener] = []
    
    internal var messages: [InboxMessage]? = nil
    private var inboxData: InboxData? = nil
    private var unreadCount: Int? = nil
    
    private var fetch: Task<Void, Error>? = nil
    
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
    
    private func notifyMessagesChanged() {
        
        let messages = messages ?? []
        let unreadCount = unreadCount ?? 0
        let totalCount = inboxData?.count ?? 0
        let canPaginate = inboxData?.messages?.pageInfo?.hasNextPage ?? false
        
        Utils.runOnMainThread { [weak self] in
            self?.listeners.forEach {
                $0.callMessageChanged(
                    messages: messages,
                    unreadMessageCount: unreadCount,
                    totalMessageCount: totalCount,
                    canPaginate: canPaginate
                )
            }
        }
        
    }
    
    private func attachLifecycleObservers() {
        
        let events = [
            UIApplication.didEnterBackgroundNotification : #selector(appDidMoveToBackground),
            UIApplication.didBecomeActiveNotification : #selector(appDidBecomeActive)
        ]
        
        // Restart the observer
        events.forEach { event in
            CoreInbox.systemNotificationCenter.removeObserver(self, name: event.key, object: nil)
            CoreInbox.systemNotificationCenter.addObserver(self, selector: event.value, name: event.key, object: nil)
        }
        
    }
    
    internal func start(refresh: Bool = false) async throws {
        
        guard let clientKey = Courier.shared.clientKey, let userId = Courier.shared.userId else {
            return
        }
        
        // Determine a safe limit
        let messageCount = messages?.count ?? paginationLimit
        let maxRefreshLimit = min(messageCount, CoreInbox.defaultMaxPaginationLimit)
        let limit = refresh ? maxRefreshLimit : paginationLimit
        
        async let dataTask: (InboxData) = inboxRepo.getAllMessages(
            clientKey: clientKey,
            userId: userId,
            paginationLimit: limit
        )
        
        async let unreadCountTask: (Int) = inboxRepo.getUnreadMessageCount(
            clientKey: clientKey,
            userId: userId
        )
        
        let (data, unreadCount) = await (try dataTask, try unreadCountTask)
        
        try await connectWebSocket(
            clientKey: clientKey,
            userId: userId
        )
        
        self.attachLifecycleObservers()
        
        self.inboxData = data
        self.unreadCount = unreadCount
        self.messages = data.messages?.nodes
        
        self.notifyMessagesChanged()
        
    }
    
    internal func restartInboxIfNeeded() async throws {
        
        // Check if we need to start the inbox pipe
        if (!listeners.isEmpty && inboxRepo.webSocket == nil) {
            
            self.notifyInitialLoading()
            try await start()
            
        }
        
    }
    
    private func connectWebSocket(clientKey: String, userId: String) async throws {
        
        // Kill existing socket
        inboxRepo.closeWebSocket()
        
        // Create a new socket
        try await inboxRepo.createWebSocket(
            clientKey: clientKey,
            userId: userId,
            onMessageReceived: { [weak self] message in
                
                // Update local values
                self?.inboxData?.incrementCount()
                self?.messages?.insert(message, at: 0)
                self?.incrementUnreadCount()

                self?.notifyMessagesChanged()
                
            },
            onMessageReceivedError: { [weak self] error in
                
                // Prevent reporting the socket disconnect error
                if (error == .inboxWebSocketDisconnect) {
                    return
                }
                
                self?.notifyError(error)
                
            }
        )
        
    }
    
    @objc private func appDidMoveToBackground() {
        inboxRepo.closeWebSocket()
    }

    @objc private func appDidBecomeActive() {
        
        if (listeners.isEmpty) {
            return
        }

        Task {
            do {
                try await self.start(refresh: true)
            } catch {
                self.notifyError(error)
            }
        }
        
    }
    
    @discardableResult internal func fetchNextPageOfMessages() async throws -> [InboxMessage] {
        
        guard let clientKey = Courier.shared.clientKey, let userId = Courier.shared.userId, let data = self.inboxData else {
            return []
        }
        
        let cursor = data.messages?.pageInfo?.startCursor
        
        self.inboxData = try await inboxRepo.getAllMessages(
            clientKey: clientKey,
            userId: userId,
            paginationLimit: paginationLimit,
            startCursor: cursor
        )
        
        let newMessages = self.inboxData?.messages?.nodes ?? []
        
        self.addPageToMessages(newMessages)
        
        self.notifyMessagesChanged()
        
        return newMessages
        
    }
    
    private func addPageToMessages(_ newMessages: [InboxMessage]) {
        
        // Add default value
        if (messages == nil) {
            messages = []
        }
        
        // Add messages to end of datasource
        self.messages! += newMessages
        
    }
    
    private func incrementUnreadCount() {
        if (self.unreadCount != nil) {
            self.unreadCount! += 1
        }
        self.unreadCount = max(0, self.unreadCount!)
    }
    
    private func decrementUnreadCount() {
        if (self.unreadCount != nil) {
            self.unreadCount! -= 1
        }
        self.unreadCount = max(0, self.unreadCount!)
    }
    
    internal func readMessage(messageId: String) async throws {
        
        guard let clientKey = Courier.shared.clientKey, let userId = Courier.shared.userId else {
            return
        }
        
        // Mark the message as read instantly
        guard let message = messages?.first(where: { $0.messageId == messageId }) else { return }
        
        // Save original state
        let originalStatus = message.read
        let prevUnreadCount = self.unreadCount
        
        // Update
        message.setRead()
        self.decrementUnreadCount()
        
        self.notifyMessagesChanged()
        
        // Perform the request async and reset if failed
        Task {
            
            do {
                
                try await inboxRepo.readMessage(
                    clientKey: clientKey,
                    userId: userId,
                    messageId: messageId
                )
                
            } catch {
                
                // Reset the status
                message.read = originalStatus
                self.unreadCount = prevUnreadCount
                self.notifyMessagesChanged()
                self.notifyError(error)
                
            }
            
        }
        
    }
    
    internal func unreadMessage(messageId: String) async throws {
        
        guard let clientKey = Courier.shared.clientKey, let userId = Courier.shared.userId else {
            return
        }
        
        // Mark the message as read instantly
        guard let message = messages?.first(where: { $0.messageId == messageId }) else { return }
        
        // Save original state
        let originalStatus = message.read
        let prevUnreadCount = self.unreadCount
        
        // Update
        message.read = nil
        self.incrementUnreadCount()
        
        self.notifyMessagesChanged()
        
        // Perform the request async and reset if failed
        Task {
            
            do {
                
                try await inboxRepo.unreadMessage(
                    clientKey: clientKey,
                    userId: userId,
                    messageId: messageId
                )
                
            } catch {
                
                // Reset the status
                message.read = originalStatus
                self.unreadCount = prevUnreadCount
                self.notifyMessagesChanged()
                self.notifyError(error)
                
            }
            
        }
        
    }
    
    internal func readAllMessages() async throws {
        
        guard let clientKey = Courier.shared.clientKey, let userId = Courier.shared.userId else {
            return
        }
        
        // Save last values
        let prevMessages = self.messages
        let prevUnreadCount = self.unreadCount
        
        // Update
        self.unreadCount = 0
        self.messages?.forEach { $0.setRead() }
        
        self.notifyMessagesChanged()
        
        // Perform the request async and reset if failed
        Task {
            
            do {
                
                try await inboxRepo.readAllMessages(
                    clientKey: clientKey,
                    userId: userId
                )
                
            } catch {
                
                // Reset the status
                self.messages = prevMessages
                self.unreadCount = prevUnreadCount
                self.notifyMessagesChanged()
                self.notifyError(error)
                
            }
            
        }
        
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
        
        // Call initial load
        Utils.runOnMainThread {
            listener.initialize()
        }
        
        // User is not signed
        if (!Courier.shared.isUserSignedIn) {
            Courier.log("User is not signed in. Please sign in to setup the inbox listener.")
            Utils.runOnMainThread {
                listener.onError?(CourierError.inboxUserNotFound)
            }
            return listener
        }
        
        if (listeners.count == 1) {
            
            fetchStart()
            
        } else if let data = inboxData, let messages = messages, let unreadCount = unreadCount {
            
            let totalMessageCount = data.count ?? 0
            let canPaginate = data.messages?.pageInfo?.hasNextPage ?? false
            
            Utils.runOnMainThread {
                listener.callMessageChanged(
                    messages: messages,
                    unreadMessageCount: unreadCount,
                    totalMessageCount: totalMessageCount,
                    canPaginate: canPaginate
                )
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
            close()
        }
        
    }
    
    internal func removeAllListeners() {
        listeners.removeAll()
        close()
    }
    
    internal func close() {
        
        // Clear out data and stop socket
        self.messages = nil
        self.inboxData = nil
        self.inboxRepo.closeWebSocket()
        
        // Tell listeners about the change
        self.notifyError(CourierError.inboxUserNotFound)
        
    }
    
    internal func refresh() async throws {
        try await start(refresh: true)
    }
    
    internal func refresh(onComplete: @escaping () -> Void) {
        Task {
            do {
                try await refresh()
            } catch {
                self.notifyError(error)
            }
            Utils.runOnMainThread {
                onComplete()
            }
        }
    }
    
    internal func fetchStart() {
        
        fetch?.cancel()
        
        fetch = Task {
            
            do {
                try await start()
            } catch {
                self.notifyError(error)
            }
            
            fetch = nil
            
        }
        
    }
    
    internal func fetchNextPage() {
        
        if (messages == nil || fetch != nil) {
            return
        }
        
        fetch?.cancel()
        
        fetch = Task {
            
            do {
                try await fetchNextPageOfMessages()
            } catch {
                self.notifyError(error)
            }
            
            fetch = nil
            
        }
        
    }
    
}

extension Courier {
    
    @objc public var inboxMessages: [InboxMessage]? {
        get {
            return inbox.messages
        }
    }
    
    @objc public var inboxPaginationLimit: Int {
        get {
            return inbox.paginationLimit
        }
        set {
            let min = min(CoreInbox.defaultMaxPaginationLimit, newValue)
            inbox.paginationLimit = max(CoreInbox.defaultMinPaginationLimit, min)
        }
    }
    
    /**
     Connects to the Courier Inbox service to handle new messages and other events that get sent to the device
     Only one websocket connection and data fetching operation will get setup when calling this.
     */
    @discardableResult @objc public func addInboxListener(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onMessagesChanged: ((_ messages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)? = nil) -> CourierInboxListener {
        return inbox.addInboxListener(onInitialLoad: onInitialLoad, onError: onError, onMessagesChanged: onMessagesChanged)
    }
    
    @objc public func removeAllInboxListeners() {
        inbox.removeAllListeners()
    }
    
    /**
     Grabs the next page of message from the inbox service
     Will automatically prevent duplicate calls if a call is already performed
     */
    @objc public func fetchNextPageOfMessages() {
        inbox.fetchNextPage()
    }
    
    /**
     Reloads and rebuilds the inbox with new messages and a new socket
     Could be used for pull to refresh functionality
     */
    @objc public func refreshInbox() async throws {
        try await inbox.refresh()
    }
    
    @objc public func refreshInbox(onComplete: @escaping () -> Void) {
        inbox.refresh(onComplete: onComplete)
    }
    
    /**
     Sets the message as `read`
     */
    @objc public func readMessage(messageId: String) async throws {
        try await inbox.readMessage(messageId: messageId)
    }
    
    @objc public func readMessage(messageId: String, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) async throws {
        Task {
            do {
                try await inbox.readMessage(messageId: messageId)
                onSuccess?()
            } catch {
                Courier.log(String(describing: error))
                onFailure?(error)
            }
        }
    }
    
    /**
     Sets the message as `unread`
     */
    @objc public func unreadMessage(messageId: String) async throws {
        try await inbox.unreadMessage(messageId: messageId)
    }
    
    @objc public func unreadMessage(messageId: String, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) async throws {
        Task {
            do {
                try await inbox.unreadMessage(messageId: messageId)
                onSuccess?()
            } catch {
                Courier.log(String(describing: error))
                onFailure?(error)
            }
        }
    }
    
    /**
     Sets `read` on all messages
     */
    @objc public func readAllInboxMessages() async throws {
        try await inbox.readAllMessages()
    }
    
    @objc public func readAllInboxMessages(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await inbox.readAllMessages()
                onSuccess?()
            } catch {
                Courier.log(String(describing: error))
                onFailure?(error)
            }
        }
    }
    
}
