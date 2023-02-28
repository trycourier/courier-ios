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
    let onMessagesChanged: ((_ newMessage: InboxMessage?, _ previousMessages: [InboxMessage], _ nextPageOfMessages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)?
    
    public init(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onMessagesChanged: ((_ newMessage: InboxMessage?, _ previousMessages: [InboxMessage], _ nextPageOfMessages: [InboxMessage], _ unreadMessageCount: Int, _ totalMessageCount: Int, _ canPaginate: Bool) -> Void)? = nil) {
        self.onInitialLoad = onInitialLoad
        self.onError = onError
        self.onMessagesChanged = onMessagesChanged
    }
    
}

extension CourierInboxListener {
    
    func callMessageChanged(newMessage: InboxMessage?, previousMessages: [InboxMessage], nextPageOfMessages: [InboxMessage], unreadMessageCount: Int, totalMessageCount: Int, canPaginate: Bool) {
        self.onMessagesChanged?(
            newMessage,
            previousMessages,
            nextPageOfMessages,
            unreadMessageCount,
            totalMessageCount,
            canPaginate
        )
    }
    
}
