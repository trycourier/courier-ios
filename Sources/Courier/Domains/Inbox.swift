//
//  CourierInbox.swift
//  
//
//  Created by Michael Miller on 3/2/23.
//

import UIKit

internal class Inbox {
    
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
        
        if let data = inboxData {
         
            let messages = messages ?? []
            let unreadCount =  -999 // TODO
            let totalCount = data.messages.totalCount ?? 0
            let canPaginate = data.messages.pageInfo.hasNextPage ?? false
            
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
        
    }
    
    private func attachLifecycleObservers() {
        
        let events = [
            UIApplication.didEnterBackgroundNotification : #selector(appDidMoveToBackground),
            UIApplication.didBecomeActiveNotification : #selector(appDidBecomeActive)
        ]
        
        // Restart the observer
        events.forEach { event in
            Inbox.systemNotificationCenter.removeObserver(self, name: event.key, object: nil)
            Inbox.systemNotificationCenter.addObserver(self, selector: event.value, name: event.key, object: nil)
        }
        
    }
    
    internal func start(refresh: Bool = false) async throws {
        
        guard let clientKey = Courier.shared.clientKey, let userId = Courier.shared.userId else {
            return
        }
        
        // Determine a safe limit
        let messageCount = messages?.count ?? paginationLimit
        let maxRefreshLimit = min(messageCount, Inbox.defaultMaxPaginationLimit)
        let limit = refresh ? maxRefreshLimit : paginationLimit
        
        let data = try await inboxRepo.getMessages(
            clientKey: clientKey,
            userId: userId,
            paginationLimit: limit
        )
        
        try await connectWebSocket(
            clientKey: clientKey,
            userId: userId
        )
        
        self.attachLifecycleObservers()
        
        self.inboxData = data
        self.messages = data.messages.nodes
        
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
                
                // Add new message to array
                self?.inboxData?.incrementCounts()
                self?.messages?.insert(message, at: 0)

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
    
    internal func fetchNextPageOfMessages() async throws {
        
        guard let clientKey = Courier.shared.clientKey, let userId = Courier.shared.userId, let data = self.inboxData else {
            return
        }
        
        let cursor = data.messages.pageInfo.startCursor
        
        self.inboxData = try await inboxRepo.getMessages(
            clientKey: clientKey,
            userId: userId,
            paginationLimit: paginationLimit,
            startCursor: cursor
        )
        
        self.addPageToMessages(data: self.inboxData)
        
        self.notifyMessagesChanged()
        
    }
    
    private func addPageToMessages(data: InboxData?) {
        
        // Add default value
        if (messages == nil) {
            messages = []
        }
        
        // Get new messages
        let nodes = data?.messages.nodes ?? []
        
        // Add messages to end of datasource
        self.messages! += nodes
        
    }
    
    internal func readAllMessages() {
        // TODO
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
            
        } else if let data = inboxData, let messages = messages {
            
            let totalMessageCount = data.messages.totalCount ?? 0
            let canPaginate = data.messages.pageInfo.hasNextPage ?? false
            
            Utils.runOnMainThread {
                listener.callMessageChanged(
                    messages: messages,
                    unreadMessageCount: -999,
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
    
    internal func removeAllInboxListeners() {
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
                Utils.runOnMainThread {
                    onComplete()
                }
            } catch {
                self.notifyError(error)
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
            let min = min(Inbox.defaultMaxPaginationLimit, newValue)
            inbox.paginationLimit = max(Inbox.defaultMinPaginationLimit, min)
        }
    }
    
    /**
     Connects to the Courier Inbox service to handle new messages and other events that get sent to the device
     Only one websocket connection and data fetching operation will get setup when calling this.
     */
    @discardableResult @objc public func addInboxListener(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onMessagesChanged: ((_ messages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)? = nil) -> CourierInboxListener {
        return inbox.addInboxListener(onInitialLoad: onInitialLoad, onError: onError, onMessagesChanged: onMessagesChanged)
    }
    
    @objc public func removeInboxListener(listener: CourierInboxListener) {
        inbox.removeInboxListener(listener: listener)
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
    
}
