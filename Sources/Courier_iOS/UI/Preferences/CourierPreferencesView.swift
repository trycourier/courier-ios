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
        customListItem: CourierPreferences.CustomListItemView? = nil,
        customLoadingState: CourierPreferences.CustomLoadingStateView? = nil,
        customEmptyState: CourierPreferences.CustomEmptyStateView? = nil,
        customErrorState: CourierPreferences.CustomErrorStateView? = nil,
        onError: ((CourierError) -> String)? = nil
    ) {
        self.preferences = CourierPreferences(
            mode: mode,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            customListItem: customListItem,
            customLoadingState: customLoadingState,
            customEmptyState: customEmptyState,
            customErrorState: customErrorState,
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

@available(iOS 15.0, *)
@available(iOSApplicationExtension, unavailable)
public extension CourierPreferencesView {
    
    struct SwiftUICustomViews {
        public let listItem: ((_ view: CourierPreferences, _ topic: CourierUserPreferencesTopic, _ section: Int, _ index: Int) -> AnyView)?
        public let loadingState: (() -> AnyView)?
        public let emptyState: ((_ onRetry: @escaping () -> Void) -> AnyView)?
        public let errorState: ((_ message: String, _ onRetry: @escaping () -> Void) -> AnyView)?
        
        public init(
            listItem: ((_ view: CourierPreferences, _ topic: CourierUserPreferencesTopic, _ section: Int, _ index: Int) -> AnyView)? = nil,
            loadingState: (() -> AnyView)? = nil,
            emptyState: ((_ onRetry: @escaping () -> Void) -> AnyView)? = nil,
            errorState: ((_ message: String, _ onRetry: @escaping () -> Void) -> AnyView)? = nil
        ) {
            self.listItem = listItem
            self.loadingState = loadingState
            self.emptyState = emptyState
            self.errorState = errorState
        }
    }
    
    private static func host<Content: View>(_ view: Content) -> UIView {
        let host = UIHostingController(rootView: view)
        host.view.backgroundColor = .clear
        return host.view
    }
    
    init(
        mode: CourierPreferences.Mode = .channels(CourierUserPreferencesChannel.allCases),
        lightTheme: CourierPreferencesTheme = .defaultLight,
        darkTheme: CourierPreferencesTheme = .defaultDark,
        swiftUICustomViews: SwiftUICustomViews,
        onError: ((CourierError) -> String)? = nil
    ) {
        self.init(
            mode: mode,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            customListItem: swiftUICustomViews.listItem.map { render in
                { view, topic, section, index in
                    CourierPreferencesView.host(render(view, topic, section, index))
                }
            },
            customLoadingState: swiftUICustomViews.loadingState.map { render in
                {
                    CourierPreferencesView.host(render())
                }
            },
            customEmptyState: swiftUICustomViews.emptyState.map { render in
                { onRetry in
                    CourierPreferencesView.host(render(onRetry))
                }
            },
            customErrorState: swiftUICustomViews.errorState.map { render in
                { message, onRetry in
                    CourierPreferencesView.host(render(message, onRetry))
                }
            },
            onError: onError
        )
    }
    
    init<CustomListItem: View>(
        mode: CourierPreferences.Mode = .channels(CourierUserPreferencesChannel.allCases),
        lightTheme: CourierPreferencesTheme = .defaultLight,
        darkTheme: CourierPreferencesTheme = .defaultDark,
        onError: ((CourierError) -> String)? = nil,
        @ViewBuilder customListItem: @escaping (_ view: CourierPreferences, _ topic: CourierUserPreferencesTopic, _ section: Int, _ index: Int) -> CustomListItem
    ) {
        self.init(
            mode: mode,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            customListItem: { view, topic, section, index in
                CourierPreferencesView.host(customListItem(view, topic, section, index))
            },
            onError: onError
        )
    }
}
