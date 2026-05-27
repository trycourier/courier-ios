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
    
    public init(
        canSwipePages: Bool = false,
        pagingDuration: TimeInterval = 0.1,
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        customTabItem: CourierInbox.CustomTabItemView? = nil,
        customListItem: CourierInbox.CustomListItemView? = nil,
        customLoadingState: CourierInbox.CustomLoadingStateView? = nil,
        customEmptyState: CourierInbox.CustomEmptyStateView? = nil,
        customErrorState: CourierInbox.CustomErrorStateView? = nil,
        customPaginationItem: CourierInbox.CustomPaginationItemView? = nil,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didLongPressInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil,
        onError: ((CourierError) -> String)? = nil
    ) {
        self.inbox = CourierInbox(
            canSwipePages: canSwipePages,
            pagingDuration: pagingDuration,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            customTabItem: customTabItem,
            customListItem: customListItem,
            customLoadingState: customLoadingState,
            customEmptyState: customEmptyState,
            customErrorState: customErrorState,
            customPaginationItem: customPaginationItem,
            didClickInboxMessageAtIndex: didClickInboxMessageAtIndex,
            didLongPressInboxMessageAtIndex: didLongPressInboxMessageAtIndex,
            didClickInboxActionForMessageAtIndex: didClickInboxActionForMessageAtIndex,
            didScrollInbox: didScrollInbox,
            onError: onError
        )
    }
    
    public func makeUIView(context: Context) -> CourierInbox {
        return inbox
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // Empty
    }
}

@available(iOSApplicationExtension, unavailable)
public extension CourierInboxView {
    
    struct SwiftUICustomViews {
        public let tabItem: ((_ feed: InboxMessageFeed, _ title: String, _ isSelected: Bool, _ unreadCount: Int?) -> AnyView)?
        public let listItem: ((_ message: InboxMessage, _ index: Int) -> AnyView)?
        public let loadingState: ((_ feed: InboxMessageFeed) -> AnyView)?
        public let emptyState: ((_ feed: InboxMessageFeed, _ onRetry: @escaping () -> Void) -> AnyView)?
        public let errorState: ((_ feed: InboxMessageFeed, _ message: String, _ onRetry: @escaping () -> Void) -> AnyView)?
        public let paginationItem: ((_ feed: InboxMessageFeed) -> AnyView)?
        
        public init(
            tabItem: ((_ feed: InboxMessageFeed, _ title: String, _ isSelected: Bool, _ unreadCount: Int?) -> AnyView)? = nil,
            listItem: ((_ message: InboxMessage, _ index: Int) -> AnyView)? = nil,
            loadingState: ((_ feed: InboxMessageFeed) -> AnyView)? = nil,
            emptyState: ((_ feed: InboxMessageFeed, _ onRetry: @escaping () -> Void) -> AnyView)? = nil,
            errorState: ((_ feed: InboxMessageFeed, _ message: String, _ onRetry: @escaping () -> Void) -> AnyView)? = nil,
            paginationItem: ((_ feed: InboxMessageFeed) -> AnyView)? = nil
        ) {
            self.tabItem = tabItem
            self.listItem = listItem
            self.loadingState = loadingState
            self.emptyState = emptyState
            self.errorState = errorState
            self.paginationItem = paginationItem
        }
    }
    
    private static func host<Content: View>(_ view: Content) -> UIView {
        let host = UIHostingController(rootView: view)
        host.view.backgroundColor = .clear
        return host.view
    }
    
    init(
        canSwipePages: Bool = false,
        pagingDuration: TimeInterval = 0.1,
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        swiftUICustomViews: SwiftUICustomViews,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didLongPressInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil,
        onError: ((CourierError) -> String)? = nil
    ) {
        self.init(
            canSwipePages: canSwipePages,
            pagingDuration: pagingDuration,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            customTabItem: swiftUICustomViews.tabItem.map { render in
                { feed, title, isSelected, unreadCount in
                    CourierInboxView.host(render(feed, title, isSelected, unreadCount))
                }
            },
            customListItem: swiftUICustomViews.listItem.map { render in
                { message, index in
                    CourierInboxView.host(render(message, index))
                }
            },
            customLoadingState: swiftUICustomViews.loadingState.map { render in
                { feed in
                    CourierInboxView.host(render(feed))
                }
            },
            customEmptyState: swiftUICustomViews.emptyState.map { render in
                { feed, onRetry in
                    CourierInboxView.host(render(feed, onRetry))
                }
            },
            customErrorState: swiftUICustomViews.errorState.map { render in
                { feed, message, onRetry in
                    CourierInboxView.host(render(feed, message, onRetry))
                }
            },
            customPaginationItem: swiftUICustomViews.paginationItem.map { render in
                { feed in
                    CourierInboxView.host(render(feed))
                }
            },
            didClickInboxMessageAtIndex: didClickInboxMessageAtIndex,
            didLongPressInboxMessageAtIndex: didLongPressInboxMessageAtIndex,
            didClickInboxActionForMessageAtIndex: didClickInboxActionForMessageAtIndex,
            didScrollInbox: didScrollInbox,
            onError: onError
        )
    }
    
    init<CustomListItem: View>(
        canSwipePages: Bool = false,
        pagingDuration: TimeInterval = 0.1,
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didLongPressInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil,
        onError: ((CourierError) -> String)? = nil,
        @ViewBuilder customListItem: @escaping (_ message: InboxMessage, _ index: Int) -> CustomListItem
    ) {
        self.init(
            canSwipePages: canSwipePages,
            pagingDuration: pagingDuration,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            customListItem: { message, index in
                CourierInboxView.host(customListItem(message, index))
            },
            didClickInboxMessageAtIndex: didClickInboxMessageAtIndex,
            didLongPressInboxMessageAtIndex: didLongPressInboxMessageAtIndex,
            didClickInboxActionForMessageAtIndex: didClickInboxActionForMessageAtIndex,
            didScrollInbox: didScrollInbox,
            onError: onError
        )
    }
}
