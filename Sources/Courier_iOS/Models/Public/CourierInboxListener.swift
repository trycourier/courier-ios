//
//  CourierInboxListener.swift
//  
//
//  Created by https://github.com/mikemilla on 2/16/23.
//

import Foundation

// MARK: Public Classes

@objc public class CourierInboxListener: NSObject {
    
    let onInitialLoad: (() -> Void)?
    let onError: ((Error) -> Void)?
    let onMessagesChanged: ((_ messages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)?
    
    private var isInitialized = false
    
    public init(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onMessagesChanged: ((_ messages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)? = nil) {
        self.onInitialLoad = onInitialLoad
        self.onError = onError
        self.onMessagesChanged = onMessagesChanged
    }
    
}

// MARK: Extensions

extension CourierInboxListener {
    
    internal func callMessageChanged(inbox: Inbox?) {
        
        if (!isInitialized) {
            return
        }
        
        let messages = inbox?.messages ?? []
        let unreadCount = inbox?.unreadCount ?? 0
        let totalCount = inbox?.totalCount ?? 0
        let canPaginate = inbox?.hasNextPage ?? false
        
        self.onMessagesChanged?(
            messages,
            unreadCount,
            totalCount,
            canPaginate
        )
        
    }
    
    internal func initialize() {
        onInitialLoad?()
        isInitialized = true
    }
    
    @objc public func remove() {
        Courier.shared.coreInbox.removeInboxListener(listener: self)
    }
    
}
