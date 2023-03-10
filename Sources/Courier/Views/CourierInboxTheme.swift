//
//  CourierInboxTheme.swift
//  
//
//  Created by Michael Miller on 3/8/23.
//

import UIKit

@objc public class CourierInboxTheme: NSObject {
    
    // MARK: Styling
    
    internal let indicatorColor: UIColor
    internal let titleFont: CourierInboxFont
    internal let timeFont: CourierInboxFont
    internal let bodyFont: CourierInboxFont
    internal let cellStyles: CourierInboxCellStyles
    
    // MARK: Init
    
    public init(
        indicatorColor: UIColor = .systemBlue,
        titleFont: CourierInboxFont = CourierInboxFont(
            font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
            color: .label
        ),
        timeFont: CourierInboxFont = CourierInboxFont(
            font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
            color: .placeholderText
        ),
        bodyFont: CourierInboxFont = CourierInboxFont(
            font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
            color: .label
        ),
        cellStyles: CourierInboxCellStyles = CourierInboxCellStyles(
            separatorStyle: .singleLine,
            separatorInsets: .init(top: 0, left: 16, bottom: 0, right: 0),
            separatorColor: nil,
            selectionStyle: .default
        )
    ) {
        self.indicatorColor = indicatorColor
        self.titleFont = titleFont
        self.timeFont = timeFont
        self.bodyFont = bodyFont
        self.cellStyles = cellStyles
    }
    
    // MARK: Defaults
    
    @objc public static let defaultDark = CourierInboxTheme()
    
    @objc public static let defaultLight = CourierInboxTheme()
    
    // MARK: Internal
    
    internal static let margin: CGFloat = 8
    internal static let titleFontSize: CGFloat = 16
    internal static let subtitleFontSize: CGFloat = 14
    
}

@objc public class CourierInboxCellStyles: NSObject {
    
    internal let separatorStyle: UITableViewCell.SeparatorStyle
    internal let separatorInsets: UIEdgeInsets
    internal let separatorColor: UIColor?
    internal let selectionStyle: UITableViewCell.SelectionStyle
    
    public init(separatorStyle: UITableViewCell.SeparatorStyle, separatorInsets: UIEdgeInsets, separatorColor: UIColor?, selectionStyle: UITableViewCell.SelectionStyle) {
        self.separatorStyle = separatorStyle
        self.separatorInsets = separatorInsets
        self.separatorColor = separatorColor
        self.selectionStyle = selectionStyle
    }
    
}

@objc public class CourierInboxFont: NSObject {
    
    internal let font: UIFont
    internal let color: UIColor
    
    public init(font: UIFont, color: UIColor) {
        self.font = font
        self.color = color
    }
    
}
