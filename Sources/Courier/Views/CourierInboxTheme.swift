//
//  CourierInboxTheme.swift
//  
//
//  Created by Michael Miller on 3/8/23.
//

import UIKit

@objc public class CourierInboxTheme: NSObject {
    
    // MARK: Styling
    
    internal let indicatorColor: UIColor?
    internal let titleFont: CourierInboxFont?
    internal let timeFont: CourierInboxFont?
    internal let bodyFont: CourierInboxFont?
    
    // MARK: Init
    
    public init(
        indicatorColor: UIColor = .systemBlue,
        titleFont: CourierInboxFont = CourierInboxFont(
            font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
            color: .label
        ),
        timeFont: CourierInboxFont = CourierInboxFont(
            font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
            color: .label
        ),
        bodyFont: CourierInboxFont = CourierInboxFont(
            font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
            color: .label
        )
    ) {
        self.indicatorColor = indicatorColor
        self.titleFont = titleFont
        self.timeFont = timeFont
        self.bodyFont = bodyFont
    }
    
    // MARK: Defaults
    
    @objc public static let defaultDark = CourierInboxTheme()
    
    @objc public static let defaultLight = CourierInboxTheme()
    
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
