//
//  CourierInboxListener.swift
//  
//
//  Created by Michael Miller on 2/16/23.
//

import Foundation

@objc public class CourierInboxListener: NSObject {
    
    let onInitialLoad: (() -> Void)?
    let onError: (() -> Void)?
    let onMessagesChanged: (([InboxMessage]) -> Void)?
    
    public init(onInitialLoad: (() -> Void)? = nil, onError: (() -> Void)? = nil, onMessagesChanged: (([InboxMessage]) -> Void)? = nil) {
        self.onInitialLoad = onInitialLoad
        self.onError = onError
        self.onMessagesChanged = onMessagesChanged
    }
    
}
