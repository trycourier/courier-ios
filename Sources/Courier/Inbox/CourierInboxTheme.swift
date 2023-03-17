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
    private let unreadIndicatorBarColor: UIColor?
    internal let loadingIndicatorColor: UIColor?
    internal let titleFont: CourierInboxFont
    internal let timeFont: CourierInboxFont
    internal let bodyFont: CourierInboxFont
    internal let detailTitleFont: CourierInboxFont
    internal let buttonStyles: CourierInboxButtonStyles
    internal let cellStyles: CourierInboxCellStyles
    
    // MARK: Init
    
    // brandId will be overridden if other colors are provided
    
    public init(
        brandId: String? = nil,
        messageAnimationStyle: UITableView.RowAnimation = .left,
        unreadIndicatorBarColor: UIColor? = nil,
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
        self.brandId = brandId
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
    
    // MARK: Brand
    
    internal var brand: CourierBrand? = nil
    
    internal var unreadColor: UIColor {
        get {
            if let customColor = unreadIndicatorBarColor {
                return customColor
            } else if let brandColor = brand?.settings?.colors?.primary {
                return .red
            } else {
                return .systemBlue
            }
        }
    }
    
    // MARK: Internal
    
    internal static let margin: CGFloat = 8
    internal static let titleFontSize: CGFloat = 16
    internal static let subtitleFontSize: CGFloat = 14
    
}

extension CourierInboxTheme {
    
    internal func attachBrand() async -> CourierInboxTheme {
        
        // Return if we have no keys, or no brandId, or an existing brand exists
        guard let clientKey = Courier.shared.clientKey, let userId = Courier.shared.userId, let brandId = brandId else {
            return self
        }
        
        // Do not continue if we have a brand already
        if let _ = self.brand {
            return self
        }
        
        do {
            
            // Grabs the brand from the server if needed
            // Sets it or fails silently
            self.brand = try await BrandsRepository().getBrand(clientKey: clientKey, userId: userId, brandId: brandId)
            
        } catch {
            
            Courier.log(error.friendlyMessage)
            
        }
        
        return self
        
    }
    
}

@objc public class CourierInboxButtonStyles: NSObject {
    
    internal let font: CourierInboxFont
    internal let backgroundColor: UIColor?
    internal let cornerRadius: CGFloat
    
    static let maxHeight: CGFloat = 34.33
    
    public init(font: CourierInboxFont = CourierInboxFont(font: UIFont.systemFont(ofSize: UIFont.labelFontSize), color: .white), backgroundColor: UIColor? = nil, cornerRadius: CGFloat = 8) {
        self.font = font
        self.backgroundColor = backgroundColor
        
        // This is the value of the container height / 2
        // This will create a perfect rounded corner
        let fullRoundedCorner = CourierInboxButtonStyles.maxHeight / 2
        
        self.cornerRadius = max(0, min(fullRoundedCorner, cornerRadius))
        
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
