//
//  CourierInboxDelegate.swift
//  
//
//  Created by Michael Miller on 3/7/23.
//

import UIKit

/**
 Delegate functions for various CourierInbox events
 */
@objc public protocol CourierInboxDelegate {
    
    /**
     Called when the user clicks on an ``InboxMessage``
     */
    @objc optional func didClickInboxMessageAtIndex(message: InboxMessage, index: Int)
    
    /**
     Called when the user clicks on an ``InboxMessage``
     */
    @objc optional func didClickInboxActionForMessageAtIndex(action: InboxAction, message: InboxMessage, index: Int)
    
    /**
     Called when the user scrolls the CourierInbox
     Returns the entire ScrollView so you can gain access to any other needed scroll events
     */
    @objc optional func didScrollInbox(scrollView: UIScrollView)
    
}
