//
//  CourierInboxDelegate.swift
//  
//
//  Created by Michael Miller on 3/7/23.
//

import UIKit

@objc public protocol CourierInboxDelegate {
    @objc optional func onMessageClick(message: InboxMessage, indexPath: IndexPath)
//    @objc optional func onMessageActionClick(message: InboxMessage, indexPath: IndexPath)
    @objc optional func inboxDidScroll(scrollView: UIScrollView)
}
