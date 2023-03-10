//
//  CourierInboxTheme.swift
//  
//
//  Created by Michael Miller on 3/8/23.
//

import UIKit

@objc public class CourierInboxTheme: NSObject {
    
    // MARK: Styling
    
    private let font: String
    private let titleTextColor: String
    private let timeTextColor: String
    private let bodyTextColor: String
    
    // MARK: Init
    
    public init(font: String? = nil, titleTextColor: String? = nil, timeTextColor: String? = nil, bodyTextColor: String? = nil) {
        self.font = font ?? CourierInboxTheme.defaultLight.font
        self.titleTextColor = titleTextColor ?? CourierInboxTheme.defaultLight.titleTextColor
        self.timeTextColor = timeTextColor ?? CourierInboxTheme.defaultLight.timeTextColor
        self.bodyTextColor = bodyTextColor ?? CourierInboxTheme.defaultLight.bodyTextColor
    }
    
    // MARK: Defaults
    
    @objc public static let defaultDark = CourierInboxTheme(
        font: "Avenir Next Bold",
        titleTextColor: "#FFAA77FF",
        timeTextColor: "#FFFFACAC",
        bodyTextColor: "#DF2E38"
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

extension CourierInboxTheme {
    
    internal var titleFontValue: UIFont {
        get {
            return UIFont(name: font, size: CourierInboxTheme.titleFontSize) ?? UIFont()
        }
    }
    
    internal var subtitleFontValue: UIFont {
        get {
            return UIFont(name: font, size: CourierInboxTheme.subtitleFontSize) ?? UIFont()
        }
    }
    
    internal var titleTextColorValue: UIColor {
        get {
            return UIColor(hex: titleTextColor) ?? .label
        }
    }
    
    internal var timeTextColorValue: UIColor {
        get {
            return UIColor(hex: timeTextColor) ?? .label
        }
    }
    
    internal var bodyTextColorValue: UIColor {
        get {
            return UIColor(hex: bodyTextColor) ?? .label
        }
    }
    
}
