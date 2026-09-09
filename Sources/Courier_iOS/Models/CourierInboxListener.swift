//
//  CourierInboxListener.swift
//  
//
//  Created by https://github.com/mikemilla on 2/16/23.
//

import Foundation

// MARK: Public Classes

// Callbacks are always delivered on the main actor, and that is now part of their type.
// The remaining state is only touched on the main actor, so the listener is safe to hand across actors.
@objc public class CourierInboxListener: NSObject, @unchecked Sendable {
    
    let onLoading: (@MainActor (_ isRefresh: Bool) -> Void)?
    let onError: (@MainActor (_ error: Error) -> Void)?
    let onUnreadCountChanged: (@MainActor (_ unreadCount: Int) -> Void)?
    let onTotalCountChanged: (@MainActor (_ totalCount: Int, _ feed: InboxMessageFeed) -> Void)?
    let onMessagesChanged: (@MainActor (_ messages: [InboxMessage], _ canPaginate: Bool, _ feed: InboxMessageFeed) -> Void)?
    let onPageAdded: (@MainActor (_ messages: [InboxMessage], _ canPaginate: Bool, _ isFirstPage: Bool, _ feed: InboxMessageFeed) -> Void)?
    let onMessageEvent: (@MainActor (_ message: InboxMessage, _ index: Int, _ feed: InboxMessageFeed, _ event: InboxMessageEvent) -> Void)?
    
    @MainActor private var isInitialized = false
    
    public init(
        onLoading: (@MainActor (_ isRefresh: Bool) -> Void)? = nil,
        onError: (@MainActor (_ error: Error) -> Void)? = nil,
        onUnreadCountChanged: (@MainActor (_ unreadCount: Int) -> Void)? = nil,
        onTotalCountChanged: (@MainActor (_ totalCount: Int, _ feed: InboxMessageFeed) -> Void)? = nil,
        onMessagesChanged: (@MainActor (_ messages: [InboxMessage], _ canPaginate: Bool, _ feed: InboxMessageFeed) -> Void)? = nil,
        onPageAdded: (@MainActor (_ messages: [InboxMessage], _ canPaginate: Bool, _ isFirstPage: Bool, _ feed: InboxMessageFeed) -> Void)? = nil,
        onMessageEvent: (@MainActor (_ message: InboxMessage, _ index: Int, _ feed: InboxMessageFeed, _ event: InboxMessageEvent) -> Void)? = nil
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
        self.onTotalCountChanged?(snapshot.feed.totalCount, .feed)
        self.onTotalCountChanged?(snapshot.archive.totalCount, .archive)
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
