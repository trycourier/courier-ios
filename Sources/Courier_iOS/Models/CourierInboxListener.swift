//
//  CourierInboxListener.swift
//  
//
//  Created by https://github.com/mikemilla on 2/16/23.
//

import Foundation

// MARK: Public Classes

@objc public class CourierInboxListener: NSObject {
    
    let onLoading: (() -> Void)?
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
        onLoading: (() -> Void)? = nil,
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

extension CourierInboxListener {
    
    internal func onLoad(data: CourierInboxData) {
        if !isInitialized {
            return
        }
        onFeedChanged?(data.feed)
        onArchiveChanged?(data.archived)
        onUnreadCountChanged?(data.unreadCount)
    }
    
    internal func initialize() {
        onLoading?()
        isInitialized = true
    }
    
    @objc public func remove() async {
        await Courier.shared.removeInboxListener(self)
    }
}
