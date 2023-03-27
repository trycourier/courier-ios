//
//  CourierInboxView.swift
//  
//
//  Created by Michael Miller on 3/27/23.
//

import SwiftUI

public struct CourierInboxView: UIViewRepresentable {
    
    private let lightTheme: CourierInboxTheme
    private let darkTheme: CourierInboxTheme
    
    public init(lightTheme: CourierInboxTheme = .defaultLight, darkTheme: CourierInboxTheme = .defaultDark) {
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
    }
    
    public func makeUIView(context: Context) -> some UIView {
        return CourierInbox(
            lightTheme: self.lightTheme,
            darkTheme: self.darkTheme
        )
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // Empty
    }
    
}
