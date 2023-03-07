//
//  CourierInboxDelegate.swift
//  
//
//  Created by Michael Miller on 3/7/23.
//

import UIKit

@objc public protocol CourierInboxDelegate {
    @objc optional func didClickMessageAtIndex(message: InboxMessage, index: Int)
    @objc optional func inboxDidScroll(scrollView: UIScrollView)
}
