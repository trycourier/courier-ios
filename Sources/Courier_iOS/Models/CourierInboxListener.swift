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
    
    internal func onInboxUpdated(_ inbox: Inbox?) {
        
        if (!isInitialized) {
            return
        }
        
        self.onMessagesChanged?(
            inbox?.messages ?? [],
            inbox?.unreadCount ?? 0,
            inbox?.totalCount ?? 0,
            inbox?.hasNextPage ?? false
        )
        
    }
    
    internal func initialize() {
        onInitialLoad?()
        isInitialized = true
    }
    
    @objc public func remove() {
        Courier.shared.removeInboxListener(self)
    }
    
}
