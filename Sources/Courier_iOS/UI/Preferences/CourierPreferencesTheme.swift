//
//  CourierPreferencesTheme.swift
//
//
//  Created by https://github.com/mikemilla on 3/5/24.
//

import UIKit

@objc public class CourierPreferencesTheme: NSObject {
    
    // MARK: Styling
    
    internal let sheetTitleFont: CourierStyles.Font
    internal let sheetSettingStyles: CourierStyles.Preferences.SettingStyles
    internal let sheetCornerRadius: CGFloat
    
    // MARK: Init
    
    public init(
        sheetTitleFont: CourierStyles.Font = CourierStyles.Font(
            font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
            color: .label
        ),
        sheetSettingStyles: CourierStyles.Preferences.SettingStyles = CourierStyles.Preferences.SettingStyles(),
        sheetCornerRadius: CGFloat = Theme.Preferences.sheetCornerRadius
    ) {
        self.sheetTitleFont = sheetTitleFont
        self.sheetSettingStyles = sheetSettingStyles
        self.sheetCornerRadius = sheetCornerRadius
    }
    
    // MARK: Defaults
    
    @objc public static let defaultDark = CourierPreferencesTheme()
    @objc public static let defaultLight = CourierPreferencesTheme()
    
}
