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
    
    private let preferences: CourierPreferences
    
    public init(
        mode: CourierPreferences.Mode = .channels(CourierUserPreferencesChannel.allCases),
        lightTheme: CourierPreferencesTheme = .defaultLight,
        darkTheme: CourierPreferencesTheme = .defaultDark,
        onError: ((CourierError) -> String)? = nil
    ) {
        self.preferences = CourierPreferences(
            mode: mode,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            onError: onError
        )
    }
    
    public func makeUIView(context: Context) -> some UIView {
        return preferences
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // Empty
    }
    
}
