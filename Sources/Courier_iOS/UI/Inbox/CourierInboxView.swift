//
//  CourierInboxView.swift
//  
//
//  Created by https://github.com/mikemilla on 3/27/23.
//

import SwiftUI

@available(iOSApplicationExtension, unavailable)
public struct CourierInboxView<Content: View>: UIViewRepresentable {
    
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
            customListItem: nil,
            didClickInboxMessageAtIndex: didClickInboxMessageAtIndex,
            didLongPressInboxMessageAtIndex: didLongPressInboxMessageAtIndex,
            didClickInboxActionForMessageAtIndex: didClickInboxActionForMessageAtIndex,
            didScrollInbox: didScrollInbox
        )
    }
    
    public init(
        canSwipePages: Bool = false,
        pagingDuration: TimeInterval = 0.1,
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didLongPressInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil,
        @ViewBuilder customListItem: @escaping (InboxMessage, Int) -> Content
    ) {
        
        // Handle the customListItem
        let wrappedCustomListItem: (InboxMessage, Int) -> UIView = { message, index in
            let hostingController = UIHostingController(rootView: customListItem(message, index))
            hostingController.view.backgroundColor = .clear
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            return hostingController.view
        }
        
        // Initialize CourierInbox with customListItem
        self.inbox = CourierInbox(
            canSwipePages: canSwipePages,
            pagingDuration: pagingDuration,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            customListItem: wrappedCustomListItem,
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
        // Handle updates if needed
    }
    
}
