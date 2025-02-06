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
        didScrollInbox: ((UIScrollView) -> Void)? = nil,
        _ customListItem: ((InboxMessage, Int) -> Content)? = nil
    ) {
        
        // Handle the optional customListItem
        let wrappedCustomListItem: ((InboxMessage, Int) -> UIView)? = customListItem.map { builder in
            return { message, index in
                let hostingController = UIHostingController(rootView: builder(message, index))
                hostingController.view.backgroundColor = .clear // Optional: Transparent background
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                return hostingController.view
            }
        }
        
        // Initialize CourierInbox with or without a customListItem
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
