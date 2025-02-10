//
//  CourierInboxView.swift
//  
//
//  Created by https://github.com/mikemilla on 3/27/23.
//

import SwiftUI

@available(iOSApplicationExtension, unavailable)
public struct CourierInboxView: UIViewRepresentable {

    public typealias UIViewType = CourierInbox
    
    private let inbox: CourierInbox

    // Unified Initializer with Optional Custom List Item
    public init(
        canSwipePages: Bool = false,
        pagingDuration: TimeInterval = 0.1,
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didLongPressInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil,
        customListItem: ((InboxMessage, Int) -> UIView)? = nil
    ) {
        // Initialize CourierInbox with optional customListItem
        self.inbox = CourierInbox(
            canSwipePages: canSwipePages,
            pagingDuration: pagingDuration,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            customListItem: customListItem,
            didClickInboxMessageAtIndex: didClickInboxMessageAtIndex,
            didLongPressInboxMessageAtIndex: didLongPressInboxMessageAtIndex,
            didClickInboxActionForMessageAtIndex: didClickInboxActionForMessageAtIndex,
            didScrollInbox: didScrollInbox
        )
    }

    public func makeUIView(context: Context) -> CourierInbox {
        return inbox
    }

    public func updateUIView(_ uiView: CourierInbox, context: Context) {
        // Handle updates if needed
    }
}

// Extension to handle SwiftUI Views as Custom List Items
public extension CourierInboxView {
    init<Content: View>(
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
        // Wrap SwiftUI View in UIHostingController
        let wrappedCustomListItem: (InboxMessage, Int) -> UIView = { message, index in
            let hostingController = UIHostingController(rootView: customListItem(message, index))
            hostingController.view.backgroundColor = .clear
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            return hostingController.view
        }

        self.init(
            canSwipePages: canSwipePages,
            pagingDuration: pagingDuration,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            didClickInboxMessageAtIndex: didClickInboxMessageAtIndex,
            didLongPressInboxMessageAtIndex: didLongPressInboxMessageAtIndex,
            didClickInboxActionForMessageAtIndex: didClickInboxActionForMessageAtIndex,
            didScrollInbox: didScrollInbox,
            customListItem: wrappedCustomListItem
        )
    }
}
