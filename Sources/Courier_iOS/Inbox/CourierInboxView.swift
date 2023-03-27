//
//  CourierInboxView.swift
//  
//
//  Created by https://github.com/mikemilla on 3/27/23.
//

import SwiftUI

public struct CourierInboxView: UIViewRepresentable {
    
    private let inbox: CourierInbox
    
    public init(
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil
    ) {
        self.inbox = CourierInbox(
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            didClickInboxMessageAtIndex: didClickInboxMessageAtIndex,
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
