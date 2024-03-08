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
        availableChannels: [CourierUserPreferencesChannel] = CourierUserPreferencesChannel.allCases,
        lightTheme: CourierPreferencesTheme = .defaultLight,
        darkTheme: CourierPreferencesTheme = .defaultDark
    ) {
        self.preferences = CourierPreferences(
            availableChannels: availableChannels,
            lightTheme: lightTheme,
            darkTheme: darkTheme
        )
    }
    
    public func makeUIView(context: Context) -> some UIView {
        return preferences
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // Empty
    }
    
}
