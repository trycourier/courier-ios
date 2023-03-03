//
//  CourierInboxListener.swift
//  
//
//  Created by Michael Miller on 2/16/23.
//

import Foundation

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

extension CourierInboxListener {
    
    func callMessageChanged(messages: [InboxMessage], unreadMessageCount: Int, totalMessageCount: Int, canPaginate: Bool) {
        
        if (!isInitialized) {
            return
        }
        
        self.onMessagesChanged?(
            messages,
            unreadMessageCount,
            totalMessageCount,
            canPaginate
        )
        
    }
    
    func initialize() {
        onInitialLoad?()
        isInitialized = true
    }
    
    @objc public func remove() {
        Courier.shared.removeInboxListener(listener: self)
    }
    
}
