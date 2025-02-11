//
//  CourierPreferencesView.swift
//
//
//  Created by https://github.com/mikemilla on 3/8/24.
//

import SwiftUI

@available(iOS 15.0, *)
@available(iOSApplicationExtension, unavailable)
public struct CourierPreferencesView: UIViewRepresentable {
    
    public typealias UIViewType = CourierPreferences

    private let preferences: CourierPreferences

    public init(
        mode: CourierPreferences.Mode = .channels(CourierUserPreferencesChannel.allCases),
        lightTheme: CourierPreferencesTheme = .defaultLight,
        darkTheme: CourierPreferencesTheme = .defaultDark,
        onError: ((CourierError) -> Void)? = nil,
        customListItem: ((CourierPreferences, CourierUserPreferencesTopic, Int, Int) -> UIView)? = nil
    ) {
        self.preferences = CourierPreferences(
            mode: mode,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            customListItem: customListItem,
            onError: onError
        )
    }

    public func makeUIView(context: Context) -> CourierPreferences {
        return preferences
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // Empty
    }
}

// Extension to handle SwiftUI Views as Custom Preference Items
@available(iOS 15.0, *)
public extension CourierPreferencesView {
    init<Content: View>(
        mode: CourierPreferences.Mode = .channels(CourierUserPreferencesChannel.allCases),
        lightTheme: CourierPreferencesTheme = .defaultLight,
        darkTheme: CourierPreferencesTheme = .defaultDark,
        onError: ((CourierError) -> Void)? = nil,
        @ViewBuilder customListItem: @escaping (CourierPreferences, CourierUserPreferencesTopic, Int, Int) -> Content
    ) {
        // Wrap SwiftUI View in UIHostingController
        let wrappedCustomListItem: (CourierPreferences, CourierUserPreferencesTopic, Int, Int) -> UIView = { view, item, section, index in
            let hostingController = UIHostingController(rootView: customListItem(view, item, section, index))
            hostingController.view.backgroundColor = .clear
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            return hostingController.view
        }

        self.init(
            mode: mode,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            onError: onError,
            customListItem: wrappedCustomListItem
        )
    }
}

