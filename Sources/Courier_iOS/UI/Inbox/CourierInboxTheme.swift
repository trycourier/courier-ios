//
//  CourierInboxTheme.swift
//  
//
//  Created by https://github.com/mikemilla on 3/8/23.
//

import UIKit

@objc public class CourierInboxTheme: NSObject {
    
    // MARK: Styling
    
    internal let brandId: String?
    internal let messageAnimationStyle: UITableView.RowAnimation
    private let loadingIndicatorColor: UIColor?
    internal let unreadIndicatorStyle: CourierStyles.Inbox.UnreadIndicatorStyle
    internal let titleStyle: CourierStyles.Inbox.TextStyle
    internal let timeStyle: CourierStyles.Inbox.TextStyle
    internal let bodyStyle: CourierStyles.Inbox.TextStyle
    internal let buttonStyle: CourierStyles.Inbox.ButtonStyle
    internal let cellStyle: CourierStyles.Cell
    internal let infoViewStyle: CourierStyles.InfoViewStyle
    
    // MARK: Init
    
    // brandId will be overridden if other colors are provided
    
    public init(
        brandId: String? = nil,
        messageAnimationStyle: UITableView.RowAnimation = .left,
        loadingIndicatorColor: UIColor? = nil,
        unreadIndicatorStyle:  CourierStyles.Inbox.UnreadIndicatorStyle =  CourierStyles.Inbox.UnreadIndicatorStyle(),
        titleStyle: CourierStyles.Inbox.TextStyle = CourierStyles.Inbox.TextStyle(
            unread: CourierStyles.Font(
                font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
                color: .label
            ),
            read: CourierStyles.Font(
                font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
                color: .secondaryLabel
            )
        ),
        timeStyle: CourierStyles.Inbox.TextStyle = CourierStyles.Inbox.TextStyle(
            unread: CourierStyles.Font(
                font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                color: .placeholderText
            ),
            read: CourierStyles.Font(
                font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                color: .tertiaryLabel
            )
        ),
        bodyStyle: CourierStyles.Inbox.TextStyle = CourierStyles.Inbox.TextStyle(
            unread: CourierStyles.Font(
                font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                color: .label
            ),
            read: CourierStyles.Font(
                font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                color: .secondaryLabel
            )
        ),
        buttonStyle: CourierStyles.Inbox.ButtonStyle = CourierStyles.Inbox.ButtonStyle(),
        cellStyle:  CourierStyles.Cell = CourierStyles.Cell(),
        infoViewStyle: CourierStyles.InfoViewStyle = CourierStyles.InfoViewStyle(
            font: CourierStyles.Font(
                font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                color: .label
            ),
            button: CourierStyles.Button(
                font: CourierStyles.Font(font: UIFont.systemFont(ofSize: UIFont.labelFontSize), color: .white)
            )
        )
    ) {
        self.brandId = brandId
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
    
}
