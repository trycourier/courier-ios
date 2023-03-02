//
//  CourierInbox.swift
//  
//
//  Created by Michael Miller on 3/2/23.
//

import UIKit

internal class Inbox {
    
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
    
    internal var messages: [InboxMessage]? = nil

    private var listeners: [CourierInboxListener] = []
    private var inboxData: InboxData? = nil
    private var pageFetch: Task<Void, Error>? = nil
    
    private func addDisplayObservers() {
        Inbox.systemNotificationCenter.addObserver(self, selector: #selector(appDidMoveToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        Inbox.systemNotificationCenter.addObserver(self, selector: #selector(appDidMoveToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    internal func start() {
        
        pageFetch?.cancel()
        
        pageFetch = Task {
            
            do {
                
                guard let clientKey = Courier.shared.clientKey, let userId = Courier.shared.userId else {
                    return
                }
                
                addDisplayObservers()
                
                inboxData = try await inboxRepo.getMessages(
                    clientKey: clientKey,
                    userId: userId,
                    paginationLimit: paginationLimit
                )
                
                try await connectWebSocket(
                    clientKey: clientKey,
                    userId: userId
                )
                
                // Reset the data
                messages = inboxData?.messages.nodes ?? []
                pageFetch = nil
                
                // Get the inbox data and notify the listeners with the details
                if let data = inboxData {
                    
                    let totalMessageCount = data.messages.totalCount ?? 0
                    let canPaginate = data.messages.pageInfo.hasNextPage ?? false
                    let previousMessages = messages ?? []
                    
                    // Call the listeners
                    Utils.runOnMainThread { [weak self] in
                        self?.listeners.forEach {
                            $0.callMessageChanged(
                                newMessage: nil,
                                previousMessages: [],
                                nextPageOfMessages: previousMessages,
                                unreadMessageCount: -999,
                                totalMessageCount: totalMessageCount,
                                canPaginate: canPaginate
                            )
                        }
                    }
                    
                }
                
            } catch {
                
                pageFetch = nil
                
                Utils.runOnMainThread { [weak self] in
                    self?.listeners.forEach {
                        $0.onError?(error)
                    }
                }
                
            }
            
        }
        
    }
    
    internal func connectIfNeeded() {
        
        // Check if we need to start the inbox pipe
        if (!listeners.isEmpty && inboxRepo.webSocket == nil) {
            
            // Notify all listeners
            Utils.runOnMainThread { [weak self] in
                self?.listeners.forEach {
                    $0.onInitialLoad?()
                }
            }
            
            // Create the inbox pipe
            start()
            
        }
        
    }
    
    private func connectWebSocket(clientKey: String, userId: String) async throws {
        
        try await inboxRepo.createWebSocket(
            clientKey: clientKey,
            userId: userId,
            onMessageReceived: { [weak self] message in
                
                // Ensure we have data to work with
                if let self = self, let data = self.inboxData {
                    
                    // Add the new message
                    self.inboxData?.incrementCounts()
                    
                    let totalMessageCount = data.messages.totalCount ?? 0
                    let canPaginate = data.messages.pageInfo.hasNextPage ?? false
                    let previousMessages = self.messages ?? []
                    
                    // Notify all listeners
                    Utils.runOnMainThread { [weak self] in
                        self?.listeners.forEach {
                            $0.callMessageChanged(
                                newMessage: message,
                                previousMessages: previousMessages,
                                nextPageOfMessages: [],
                                unreadMessageCount: -999,
                                totalMessageCount: totalMessageCount,
                                canPaginate: canPaginate
                            )
                        }
                    }
                    
                    // Add the message to the array
                    self.messages?.insert(message, at: 0)
                    
                }
                
            },
            onMessageReceivedError: { [weak self] error in
                
                // Notify all listeners
                Utils.runOnMainThread { [weak self] in
                    self?.listeners.forEach {
                        $0.onError?(error)
                    }
                }
                
            }
        )
        
    }
    
    @objc private func appDidMoveToBackground() {
        inboxRepo.closeWebSocket()
    }

    @objc private func appDidMoveToForeground() {
        
        if (listeners.isEmpty) {
            return
        }
        
        guard let clientKey = Courier.shared.clientKey, let userId = Courier.shared.userId else {
            return
        }
        
        Task {
            
            do {
                
//                let data = try await inboxRepo.getMessages(
//                    clientKey: clientKey,
//                    userId: userId,
//                    paginationLimit: paginationLimit
//                )
//
//                print("TODO")
//                print(data)
                
                try await connectWebSocket(
                    clientKey: clientKey,
                    userId: userId
                )
                
            } catch {
                
                Utils.runOnMainThread { [weak self] in
                    self?.listeners.forEach {
                        $0.onError?(error)
                    }
                }
                
            }
            
        }
        
    }
    
    internal func fetchNextPageOfMessages() {
        
        // Block if already fetching
        if (pageFetch != nil) {
            return
        }
        
        pageFetch = Task {
            
            do {
                
                guard let clientKey = Courier.shared.clientKey, let userId = Courier.shared.userId, let data = self.inboxData else {
                    return
                }
                
                let previousMessages = messages ?? []
                let cursor = data.messages.pageInfo.startCursor
                
                self.inboxData = try await inboxRepo.getMessages(
                    clientKey: clientKey,
                    userId: userId,
                    paginationLimit: paginationLimit,
                    startCursor: cursor
                )
                
                // Set empty array if needed
                if (messages == nil) {
                    messages = []
                }
                
                messages! += self.inboxData?.messages.nodes ?? []
                pageFetch = nil
                
                if let data = inboxData {
                 
                    // Hold previous messages
                    let nextPageOfMessages = data.messages.nodes
                    let totalMessageCount = data.messages.totalCount ?? 0
                    let canPaginate = data.messages.pageInfo.hasNextPage ?? false
                    
                    // Call the listeners
                    Utils.runOnMainThread { [weak self] in
                        self?.listeners.forEach {
                            $0.callMessageChanged(
                                newMessage: nil,
                                previousMessages: previousMessages,
                                nextPageOfMessages: nextPageOfMessages,
                                unreadMessageCount: -999,
                                totalMessageCount: totalMessageCount,
                                canPaginate: canPaginate
                            )
                        }
                    }
                    
                }
                
            } catch {
                
                pageFetch = nil
                
                Utils.runOnMainThread { [weak self] in
                    self?.listeners.forEach {
                        $0.onError?(error)
                    }
                }
                
            }
            
        }
        
    }
    
    internal func readAllMessages() {
        // TODO
    }
    
    internal func addInboxListener(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onMessagesChanged: ((_ newMessage: InboxMessage?, _ previousMessages: [InboxMessage], _ nextPageOfMessages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)? = nil) -> CourierInboxListener {
        
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
            listener.onInitialLoad?()
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
            
            start()
            
        } else if let data = inboxData, let messages = messages {
            
            let totalMessageCount = (data.messages.totalCount ?? 0) + 1
            let canPaginate = data.messages.pageInfo.hasNextPage ?? false
            
            listener.callMessageChanged(
                newMessage: nil,
                previousMessages: [],
                nextPageOfMessages: messages,
                unreadMessageCount: -999,
                totalMessageCount: totalMessageCount,
                canPaginate: canPaginate
            )
            
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
        
        // Remove all inbox details
        // Keep the listeners still registered
        messages = nil
        inboxRepo.closeWebSocket()
        
        // Tell all the listeners the user is signed out
        Utils.runOnMainThread { [weak self] in
            self?.listeners.forEach {
                $0.onError?(CourierError.inboxUserNotFound)
            }
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
    @discardableResult @objc public func addInboxListener(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onMessagesChanged: ((_ newMessage: InboxMessage?, _ previousMessages: [InboxMessage], _ nextPageOfMessages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)? = nil) -> CourierInboxListener {
        return inbox.addInboxListener(onInitialLoad: onInitialLoad, onError: onError, onMessagesChanged: onMessagesChanged)
    }
    
    /**
     Grabs the next page of message from the inbox service
     Will automatically prevent duplicate calls if a call is already performed
     */
    @objc public func fetchNextPageOfMessages() {
        inbox.fetchNextPageOfMessages()
    }
    
}
