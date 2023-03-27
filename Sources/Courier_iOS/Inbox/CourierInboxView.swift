//
//  CourierInboxView.swift
//  
//
//  Created by Michael Miller on 3/27/23.
//

import SwiftUI

public struct CourierInboxView: UIViewRepresentable {
    
    private let inbox: CourierInbox
    
    public init(
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil)
    {
        self.inbox = CourierInbox(
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            didClickInboxMessageAtIndex: didClickInboxMessageAtIndex
        )
    }
    
    public func makeUIView(context: Context) -> some UIView {
        return inbox
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // Empty
    }
    
    // MARK: Courier Inbox
    
    public func didClickInboxMessageAtIndex(message: InboxMessage, index: Int) {
        print(message)
    }
    
    public func didClickInboxActionForMessageAtIndex(action: InboxAction, message: InboxMessage, index: Int) {
        print(message, action)
    }
    
    public func didScrollInbox(scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }
    
}
