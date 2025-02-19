//
//  CourierInboxListener.swift
//  
//
//  Created by https://github.com/mikemilla on 2/16/23.
//

import Foundation

// MARK: Public Classes

@objc public class CourierInboxListener: NSObject {
    
    let onLoading: ((Bool) -> Void)?
    let onError: ((Error) -> Void)?
    let onUnreadCountChanged: ((_ count: Int) -> Void)?
    let onFeedChanged: ((_ messageSet: InboxMessageSet) -> Void)?
    let onArchiveChanged: ((_ messageSet: InboxMessageSet) -> Void)?
    let onPageAdded: ((_ feed: InboxMessageFeed, _ messageSet: InboxMessageSet) -> Void)?
    let onMessageChanged: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)?
    let onMessageAdded: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)?
    let onMessageRemoved: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)?
    
    private var isInitialized = false
    
    public init(
        onLoading: ((Bool) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onUnreadCountChanged: ((_ count: Int) -> Void)? = nil,
        onFeedChanged: ((_ messageSet: InboxMessageSet) -> Void)? = nil,
        onArchiveChanged: ((_ messageSet: InboxMessageSet) -> Void)? = nil,
        onPageAdded: ((_ feed: InboxMessageFeed, _ messageSet: InboxMessageSet) -> Void)? = nil,
        onMessageChanged: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)? = nil,
        onMessageAdded: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)? = nil,
        onMessageRemoved: ((_ feed: InboxMessageFeed, _ index: Int, _ message: InboxMessage) -> Void)? = nil
    ) {
        self.onLoading = onLoading
        self.onError = onError
        self.onUnreadCountChanged = onUnreadCountChanged
        self.onFeedChanged = onFeedChanged
        self.onArchiveChanged = onArchiveChanged
        self.onPageAdded = onPageAdded
        self.onMessageChanged = onMessageChanged
        self.onMessageAdded = onMessageAdded
        self.onMessageRemoved = onMessageRemoved
    }
}

// MARK: - Extensions

@CourierActor extension CourierInboxListener {
    
    internal func onLoad(data: CourierInboxData) async {
        if !self.isInitialized {
            return
        }
        
        // Capture the values before switching to MainActor
        let feed = data.feed
        let archived = data.archived
        let unreadCount = data.unreadCount

        await MainActor.run {
            self.onFeedChanged?(feed)
            self.onArchiveChanged?(archived)
            self.onUnreadCountChanged?(unreadCount)
        }
    }

    
    internal func initialize() async {
        await MainActor.run {
            self.onLoading?(false)
            self.isInitialized = true
        }
    }
    
}

extension CourierInboxListener {
    
    @objc public func remove() {
//        Task {
//            await Courier.shared.removeInboxListener(self)
//        }
    }
    
}

@objc public class NewCourierInboxListener: NSObject {
    
    let onLoading: ((_ isRefresh: Bool) -> Void)?
    let onError: ((_ error: Error) -> Void)?
    let onUnreadCountChanged: ((_ unreadCount: Int) -> Void)?
    let onTotalCountChanged: ((_ totalCount: Int, _ feed: InboxMessageFeed) -> Void)?
    let onMessagesChanged: ((_ message: [InboxMessage], _ canPaginate: Bool, _ feed: InboxMessageFeed) -> Void)?
    let onMessageEvent: ((_ message: InboxMessage, _ index: Int, _ feed: InboxMessageFeed, _ event: InboxMessageEvent) -> Void)?
    
    private var isInitialized = false
    
    public init(
        onLoading: ((_ isRefresh: Bool) -> Void)? = nil,
        onError: ((_ error: Error) -> Void)? = nil,
        onUnreadCountChanged: ((_ unreadCount: Int) -> Void)? = nil,
        onTotalCountChanged: ((_ totalCount: Int, _ feed: InboxMessageFeed) -> Void)? = nil,
        onMessagesChanged: ((_ message: [InboxMessage], _ canPaginate: Bool, _ feed: InboxMessageFeed) -> Void)? = nil,
        onMessageEvent: ((_ message: InboxMessage, _ index: Int, _ feed: InboxMessageFeed, _ event: InboxMessageEvent) -> Void)? = nil
    ) {
        self.onLoading = onLoading
        self.onError = onError
        self.onUnreadCountChanged = onUnreadCountChanged
        self.onTotalCountChanged = onTotalCountChanged
        self.onMessagesChanged = onMessagesChanged
        self.onMessageEvent = onMessageEvent
    }
    
    @MainActor
    internal func onLoad(_ snapshot: (feed: InboxMessageDataSet, archive: InboxMessageDataSet, unreadCount: Int)) {
        if !self.isInitialized { return }
        self.onMessagesChanged?(snapshot.feed.messages, snapshot.feed.canPaginate, .feed)
        self.onMessagesChanged?(snapshot.archive.messages, snapshot.archive.canPaginate, .archive)
        self.onUnreadCountChanged?(snapshot.unreadCount)
    }
    
    @MainActor
    internal func initialize() {
        self.onLoading?(false)
        self.isInitialized = true
    }
    
    @MainActor
    internal func error(_ error: Error) {
        self.onError?(error)
    }
    
}

extension NewCourierInboxListener {
    
    @objc public func remove() {
        Task {
            await Courier.shared.removeInboxListener(self)
        }
    }
    
}
