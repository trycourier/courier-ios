//
//  CourierInboxView.swift
//  
//
//  Created by https://github.com/mikemilla on 3/27/23.
//

import SwiftUI

@available(iOSApplicationExtension, unavailable)
public struct CourierInboxView: UIViewRepresentable {
    
    private let inbox: CourierInbox
    
    public init(
        canSwipePages: Bool = false,
        pagingDuration: TimeInterval = 0.1,
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didLongPressInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil
    ) {
        self.inbox = CourierInbox(
            canSwipePages: canSwipePages,
            pagingDuration: pagingDuration,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            didClickInboxMessageAtIndex: didClickInboxMessageAtIndex,
            didLongPressInboxMessageAtIndex: didLongPressInboxMessageAtIndex,
            didClickInboxActionForMessageAtIndex: didClickInboxActionForMessageAtIndex,
            didScrollInbox: didScrollInbox
        )
    }
    
    public func makeUIView(context: Context) -> some UIView {
        return inbox
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // Empty
    }
    
}
