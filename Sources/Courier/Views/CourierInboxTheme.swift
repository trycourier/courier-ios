//
//  CourierInboxTheme.swift
//  
//
//  Created by Michael Miller on 3/8/23.
//

import UIKit

@objc public class CourierInboxTheme: NSObject {
    
    // MARK: Styling
    
    internal let titleFont: CourierInboxFont?
    internal let timeFont: CourierInboxFont?
    internal let bodyFont: CourierInboxFont?
    
    // MARK: Init
    
    public init(titleFont: CourierInboxFont? = nil, timeFont: CourierInboxFont? = nil, bodyFont: CourierInboxFont? = nil) {
        self.titleFont = titleFont
        self.timeFont = timeFont
        self.bodyFont = bodyFont
    }
    
    // MARK: Defaults
    
    @objc public static let defaultDark = CourierInboxTheme(
        titleFont: CourierInboxFont(
            font: UIFont.boldSystemFont(ofSize: CourierInboxTheme.titleFontSize),
            color: .label
        ),
        timeFont: CourierInboxFont(
            font: UIFont.boldSystemFont(ofSize: CourierInboxTheme.titleFontSize),
            color: .label
        ),
        bodyFont: CourierInboxFont(
            font: UIFont.systemFont(ofSize: CourierInboxTheme.subtitleFontSize),
            color: .label
        )
    )
    
    @objc public static let defaultLight = CourierInboxTheme(
//        font: "Charter Black",
//        titleTextColor: "#ffe700ff",
//        timeTextColor: "#ffe700ff",
//        bodyTextColor: "#ffe700ff"
    )
    
    // MARK: Internal
    
    internal static let margin: CGFloat = 8
    internal static let titleFontSize: CGFloat = 16
    internal static let subtitleFontSize: CGFloat = 14
    
}

@objc public class CourierInboxFont: NSObject {
    
    internal let font: UIFont?
    internal let color: UIColor?
    
    public init(font: UIFont? = nil, color: UIColor? = nil) {
        self.font = font
        self.color = color
    }
    
}
