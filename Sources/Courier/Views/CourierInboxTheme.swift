//
//  CourierInboxTheme.swift
//  
//
//  Created by Michael Miller on 3/8/23.
//

import UIKit

@objc public class CourierInboxTheme: NSObject {
    
    // MARK: Styling
    
    @objc public let font: String
    @objc public let textColor: String
    
    // MARK: Init
    
    public init(font: String? = nil, textColor: String? = nil) {
        self.font = font ?? CourierInboxTheme.defaultLight.font
        self.textColor = textColor ?? CourierInboxTheme.defaultLight.textColor
    }
    
    // MARK: Defaults
    
    @objc public static let defaultDark = CourierInboxTheme(
        font: "Avenir Next Bold",
        textColor: "#ffe700ff"
    )
    
    @objc public static let defaultLight = CourierInboxTheme(
        font: "Charter Black",
        textColor: "michael"
    )
    
    // MARK: Internal
    
    internal static let margin: CGFloat = 8
    
}

extension CourierInboxTheme {
    
    internal var fontValue: UIFont {
        get {
            return UIFont(name: font, size: 16) ?? UIFont()
        }
    }
    
    internal var textColorValue: UIColor {
        get {
            return UIColor(hex: textColor) ?? .systemRed
        }
    }
    
}
