//
//  CourierInboxListener.swift
//  
//
//  Created by https://github.com/mikemilla on 2/16/23.
//

import Foundation

// MARK: Public Classes

@objc public class CourierInboxListener: NSObject {
    
    let onLoading: ((_ isRefresh: Bool) -> Void)?
    let onError: ((_ error: Error) -> Void)?
    let onUnreadCountChanged: ((_ unreadCount: Int) -> Void)?
    let onTotalCountChanged: ((_ totalCount: Int, _ feed: InboxMessageFeed) -> Void)?
    let onMessagesChanged: ((_ message: [InboxMessage], _ canPaginate: Bool, _ feed: InboxMessageFeed) -> Void)?
    let onPageAdded: ((_ message: [InboxMessage], _ canPaginate: Bool, _ isFirstPage: Bool, _ feed: InboxMessageFeed) -> Void)?
    let onMessageEvent: ((_ message: InboxMessage, _ index: Int, _ feed: InboxMessageFeed, _ event: InboxMessageEvent) -> Void)?
    
    private var isInitialized = false
    
    public init(
        onLoading: ((_ isRefresh: Bool) -> Void)? = nil,
        onError: ((_ error: Error) -> Void)? = nil,
        onUnreadCountChanged: ((_ unreadCount: Int) -> Void)? = nil,
        onTotalCountChanged: ((_ totalCount: Int, _ feed: InboxMessageFeed) -> Void)? = nil,
        onMessagesChanged: ((_ message: [InboxMessage], _ canPaginate: Bool, _ feed: InboxMessageFeed) -> Void)? = nil,
        onPageAdded: ((_ message: [InboxMessage], _ canPaginate: Bool, _ isFirstPage: Bool, _ feed: InboxMessageFeed) -> Void)? = nil,
        onMessageEvent: ((_ message: InboxMessage, _ index: Int, _ feed: InboxMessageFeed, _ event: InboxMessageEvent) -> Void)? = nil
    ) {
        self.onLoading = onLoading
        self.onError = onError
        self.onUnreadCountChanged = onUnreadCountChanged
        self.onTotalCountChanged = onTotalCountChanged
        self.onMessagesChanged = onMessagesChanged
        self.onPageAdded = onPageAdded
        self.onMessageEvent = onMessageEvent
    }
    
    @MainActor
    internal func onLoad(_ snapshot: (feed: InboxMessageSet, archive: InboxMessageSet, unreadCount: Int)) {
        if !self.isInitialized { return }
        self.onPageAdded?(snapshot.feed.messages, snapshot.feed.canPaginate, true, .feed)
        self.onPageAdded?(snapshot.archive.messages, snapshot.archive.canPaginate, true, .archive)
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

extension CourierInboxListener {
    
    @objc public func remove() {
        Task {
            await Courier.shared.removeInboxListener(self)
        }
    }
    
}
