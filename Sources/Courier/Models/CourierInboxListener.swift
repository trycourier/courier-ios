//
//  CourierInboxListener.swift
//  
//
//  Created by Michael Miller on 2/16/23.
//

import Foundation

@objc public class CourierInboxListener: NSObject {
    
    let onInitialLoad: () -> Void
    let onError: () -> Void
    let onMessagesChanged: (Int) -> Void
    
    public init(onInitialLoad: @escaping () -> Void, onError: @escaping () -> Void, onMessagesChanged: @escaping (Int) -> Void) {
        self.onInitialLoad = onInitialLoad
        self.onError = onError
        self.onMessagesChanged = onMessagesChanged
    }
    
}
