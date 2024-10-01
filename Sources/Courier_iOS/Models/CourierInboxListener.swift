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
    let onInboxChanged: ((_ inbox: CourierInboxData) -> Void)?
    
    private var isInitialized = false
    
    public init(onInitialLoad: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onInboxChanged: ((_ inbox: CourierInboxData) -> Void)? = nil) {
        self.onInitialLoad = onInitialLoad
        self.onError = onError
        self.onInboxChanged = onInboxChanged
    }
    
}

// MARK: Extensions

extension CourierInboxListener {
    
    internal func onInboxUpdated(_ inbox: CourierInboxData) {
        
        if (!isInitialized) {
            return
        }
        
        self.onInboxChanged?(inbox)
        
    }
    
    internal func initialize() {
        onInitialLoad?()
        isInitialized = true
    }
    
    @objc public func remove() {
        Courier.shared.removeInboxListener(self)
    }
    
}
