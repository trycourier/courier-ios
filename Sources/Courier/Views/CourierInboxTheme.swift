//
//  CourierInboxTheme.swift
//  
//
//  Created by Michael Miller on 3/8/23.
//

import UIKit

@objc public class CourierInboxTheme: NSObject {
    
    // MARK: Styling
    
    private let font: String?
    private let titleTextColor: String?
    private let timeTextColor: String?
    private let bodyTextColor: String?
    
    // MARK: Init
    
    public init(font: String? = nil, titleTextColor: String? = nil, timeTextColor: String? = nil, bodyTextColor: String? = nil) {
        self.font = font
        self.titleTextColor = titleTextColor
        self.timeTextColor = timeTextColor
        self.bodyTextColor = bodyTextColor
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
            let defaultFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            guard let font = self.font else { return defaultFont }
            return UIFont(name: font, size: CourierInboxTheme.titleFontSize) ?? defaultFont
        }
    }
    
    internal var subtitleFontValue: UIFont {
        get {
            let defaultFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            guard let font = self.font else { return defaultFont }
            return UIFont(name: font, size: CourierInboxTheme.subtitleFontSize) ?? defaultFont
        }
    }
    
    internal var titleTextColorValue: UIColor {
        get {
            guard let color = self.titleTextColor else { return .label }
            return UIColor(hex: color) ?? .label
        }
    }
    
    internal var timeTextColorValue: UIColor {
        get {
            guard let color = self.timeTextColor else { return .label }
            return UIColor(hex: color) ?? .label
        }
    }
    
    internal var bodyTextColorValue: UIColor {
        get {
            guard let color = self.bodyTextColor else { return .label }
            return UIColor(hex: color) ?? .label
        }
    }
    
}
