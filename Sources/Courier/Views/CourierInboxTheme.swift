//
//  CourierInboxTheme.swift
//  
//
//  Created by Michael Miller on 3/8/23.
//

import UIKit

@objc public class CourierInboxTheme: NSObject {
    
    // MARK: Styling
    
    @objc public let textColor: UIColor
    
    // MARK: Init
    
    public init(textColor: UIColor? = nil) {
        self.textColor = textColor ?? CourierInboxTheme.defaultDark.textColor
    }
    
    // MARK: Defaults
    
    @objc public static let defaultDark = CourierInboxTheme(
        textColor: .red
    )
    
    @objc public static let defaultLight = CourierInboxTheme(
        textColor: .blue
    )
    
    // MARK: Internal
    
    internal static let margin: CGFloat = 8
    
}
