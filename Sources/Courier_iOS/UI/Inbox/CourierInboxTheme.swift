//
//  CourierInboxTheme.swift
//  
//
//  Created by https://github.com/mikemilla on 3/8/23.
//

import UIKit

@objc public class CourierInboxTheme: NSObject {
    
    // MARK: Styling
    
    internal let messageAnimationStyle: UITableView.RowAnimation
    private let loadingIndicatorColor: UIColor?
    internal let unreadIndicatorStyle: CourierInboxUnreadIndicatorStyle
    internal let titleStyle: CourierInboxTextStyle
    internal let timeStyle: CourierInboxTextStyle
    internal let bodyStyle: CourierInboxTextStyle
    internal let buttonStyle: CourierInboxButtonStyle
    internal let cellStyle: CourierInboxCellStyle
    internal let infoViewStyle: CourierInboxInfoViewStyle
    
    // MARK: Init
    
    // brandId will be overridden if other colors are provided
    
    public init(
        messageAnimationStyle: UITableView.RowAnimation = .left,
        loadingIndicatorColor: UIColor? = nil,
        unreadIndicatorStyle: CourierInboxUnreadIndicatorStyle = CourierInboxUnreadIndicatorStyle(),
        titleStyle: CourierInboxTextStyle = CourierInboxTextStyle(
            unread: CourierInboxFont(
                font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
                color: .label
            ),
            read: CourierInboxFont(
                font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
                color: .secondaryLabel
            )
        ),
        timeStyle: CourierInboxTextStyle = CourierInboxTextStyle(
            unread: CourierInboxFont(
                font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                color: .placeholderText
            ),
            read: CourierInboxFont(
                font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                color: .tertiaryLabel
            )
        ),
        bodyStyle: CourierInboxTextStyle = CourierInboxTextStyle(
            unread: CourierInboxFont(
                font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                color: .label
            ),
            read: CourierInboxFont(
                font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                color: .secondaryLabel
            )
        ),
        buttonStyle: CourierInboxButtonStyle = CourierInboxButtonStyle(),
        cellStyle: CourierInboxCellStyle = CourierInboxCellStyle(),
        infoViewStyle: CourierInboxInfoViewStyle = CourierInboxInfoViewStyle(
            font: CourierInboxFont(
                font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                color: .label
            ),
            button: CourierInboxButton(
                font: CourierInboxFont(font: UIFont.systemFont(ofSize: UIFont.labelFontSize), color: .white)
            )
        )
    ) {
        self.messageAnimationStyle = messageAnimationStyle
        self.unreadIndicatorStyle = unreadIndicatorStyle
        self.loadingIndicatorColor = loadingIndicatorColor
        self.titleStyle = titleStyle
        self.timeStyle = timeStyle
        self.bodyStyle = bodyStyle
        self.buttonStyle = buttonStyle
        self.cellStyle = cellStyle
        self.infoViewStyle = infoViewStyle
    }
    
    // MARK: Defaults
    
    @objc public static let defaultDark = CourierInboxTheme()
    @objc public static let defaultLight = CourierInboxTheme()
    
    // MARK: Brand
    
    internal var brand: CourierBrand? = nil
    
    internal var unreadColor: UIColor {
        get {
            if let customColor = unreadIndicatorStyle.color {
                return customColor
            } else if let brandColor = UIColor(brand?.settings?.colors?.primary ?? "") {
                return brandColor
            } else {
                return .systemBlue
            }
        }
    }
    
    internal var loadingColor: UIColor? {
        get {
            if let customColor = loadingIndicatorColor {
                return customColor
            } else if let brandColor = UIColor(brand?.settings?.colors?.primary ?? "") {
                return brandColor
            } else {
                return nil
            }
        }
    }
    
    internal func getInfoButtonColor() -> UIColor {
        if let customColor = infoViewStyle.button.backgroundColor {
            return customColor
        } else if let brandColor = UIColor(brand?.settings?.colors?.primary ?? "") {
            return brandColor
        } else {
            return .systemBlue
        }
    }
    
    internal func getButtonColor(isRead: Bool) -> UIColor {
        
        let styleColor = isRead ? buttonStyle.read.backgroundColor : buttonStyle.unread.backgroundColor
        
        if let customColor = styleColor {
            return customColor
        } else if let brandColor = UIColor(brand?.settings?.colors?.primary ?? "") {
            return brandColor
        } else {
            return isRead ? .systemGray : .systemBlue
        }
        
    }
    
    // MARK: Internal
    
    internal static let margin: CGFloat = 8
    internal static let titleFontSize: CGFloat = 16
    internal static let subtitleFontSize: CGFloat = 14
    
    // MARK: Courier Brand
    
    internal static let lightBrandColor: UIColor = UIColor("73819B") ?? .black
    internal static let darkBrandColor: UIColor = .white
    
}

@objc public class CourierInboxButtonStyle: NSObject {
    
    internal let unread: CourierInboxButton
    internal let read: CourierInboxButton
    
    internal static let maxHeight: CGFloat = 34.33
    
    public init(
        unread: CourierInboxButton = CourierInboxButton(
            font: CourierInboxFont(font: UIFont.systemFont(ofSize: UIFont.labelFontSize), color: .white)
        ),
        read: CourierInboxButton = CourierInboxButton(
            font: CourierInboxFont(font: UIFont.systemFont(ofSize: UIFont.labelFontSize), color: .white)
        )
    ) {
        self.unread = unread
        self.read = read
    }
    
}

@objc public class CourierInboxButton: NSObject {
    
    internal let font: CourierInboxFont
    internal let backgroundColor: UIColor?
    internal let cornerRadius: CGFloat
    
    public init(font: CourierInboxFont, backgroundColor: UIColor? = nil, cornerRadius: CGFloat = 8) {
        
        self.font = font
        self.backgroundColor = backgroundColor
        
        // This is the value of the container height / 2
        // This will create a perfect rounded corner
        let fullRoundedCorner = CourierInboxButtonStyle.maxHeight / 2
        
        self.cornerRadius = max(0, min(fullRoundedCorner, cornerRadius))
        
    }
    
}

@objc public class CourierInboxCellStyle: NSObject {
    
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

@objc public class CourierInboxTextStyle: NSObject {
    
    internal let unread: CourierInboxFont
    internal let read: CourierInboxFont
    
    public init(unread: CourierInboxFont, read: CourierInboxFont) {
        self.unread = unread
        self.read = read
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

public enum CourierInboxUnreadIndicator {
    case line
    case dot
}

@objc public class CourierInboxUnreadIndicatorStyle: NSObject {
    
    internal let indicator: CourierInboxUnreadIndicator
    internal let color: UIColor?
    
    public init(indicator: CourierInboxUnreadIndicator = .line, color: UIColor? = nil) {
        self.indicator = indicator
        self.color = color
    }
    
}

@objc public class CourierInboxInfoViewStyle: NSObject {
    
    internal let font: CourierInboxFont
    internal let button: CourierInboxButton
    
    public init(font: CourierInboxFont, button: CourierInboxButton) {
        self.font = font
        self.button = button
    }
    
}
