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
    let onMessagesChanged: ((_ unreadMessageCount: Int, _ totalMessageCount: Int, _ previousMessages: [InboxMessage], _ newMessages: [InboxMessage], _ canPaginate: Bool) -> Void)?
    
    public init(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onMessagesChanged: ((_ unreadMessageCount: Int, _ totalMessageCount: Int, _ previousMessages: [InboxMessage], _ newMessages: [InboxMessage], _ canPaginate: Bool) -> Void)? = nil) {
        self.onInitialLoad = onInitialLoad
        self.onError = onError
        self.onMessagesChanged = onMessagesChanged
    }
    
}

extension CourierInboxListener {
    
    func callMessageChanged(unreadMessageCount: Int, totalMessageCount: Int, previousMessages: [InboxMessage], newMessages: [InboxMessage], canPaginate: Bool) {
        self.onMessagesChanged?(
            unreadMessageCount,
            totalMessageCount,
            previousMessages,
            newMessages,
            canPaginate
        )
    }
    
}
