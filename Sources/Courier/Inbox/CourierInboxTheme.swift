//
//  CourierInboxTheme.swift
//  
//
//  Created by Michael Miller on 3/8/23.
//

import UIKit

@objc public class CourierInboxTheme: NSObject {
    
    // MARK: Styling
    
    internal let messageAnimationStyle: UITableView.RowAnimation
    internal let unreadIndicatorBarColor: UIColor
    internal let loadingIndicatorColor: UIColor?
    internal let titleFont: CourierInboxFont
    internal let timeFont: CourierInboxFont
    internal let bodyFont: CourierInboxFont
    internal let detailTitleFont: CourierInboxFont
    internal let buttonStyles: CourierInboxButtonStyles
    internal let cellStyles: CourierInboxCellStyles
    
    // MARK: Init
    
    public init(
        messageAnimationStyle: UITableView.RowAnimation = .left,
        unreadIndicatorBarColor: UIColor = .systemBlue,
        loadingIndicatorColor: UIColor? = nil,
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
        detailTitleFont: CourierInboxFont = CourierInboxFont(
            font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
            color: .label
        ),
        buttonStyles: CourierInboxButtonStyles = CourierInboxButtonStyles(),
        cellStyles: CourierInboxCellStyles = CourierInboxCellStyles()
    ) {
        self.messageAnimationStyle = messageAnimationStyle
        self.unreadIndicatorBarColor = unreadIndicatorBarColor
        self.loadingIndicatorColor = loadingIndicatorColor
        self.titleFont = titleFont
        self.timeFont = timeFont
        self.bodyFont = bodyFont
        self.detailTitleFont = detailTitleFont
        self.buttonStyles = buttonStyles
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

@objc public class CourierInboxButtonStyles: NSObject {
    
    internal let font: CourierInboxFont
    internal let backgroundColor: UIColor
    internal let cornerRadius: CGFloat
    
    public init(font: CourierInboxFont = CourierInboxFont(font: UIFont.systemFont(ofSize: UIFont.labelFontSize), color: .white), backgroundColor: UIColor = .systemBlue, cornerRadius: CGFloat = 8) {
        self.font = font
        self.backgroundColor = backgroundColor
        self.cornerRadius = max(0, min(34.33, cornerRadius))
    }
    
}

@objc public class CourierInboxCellStyles: NSObject {
    
    internal let separatorStyle: UITableViewCell.SeparatorStyle
    internal let separatorInsets: UIEdgeInsets
    internal let separatorColor: UIColor?
    internal let selectionStyle: UITableViewCell.SelectionStyle
    
    public init(separatorStyle: UITableViewCell.SeparatorStyle = .singleLine, separatorInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 0), separatorColor: UIColor? = nil, selectionStyle: UITableViewCell.SelectionStyle = .default) {
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
