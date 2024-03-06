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
    internal let sheetCellStyles: CourierStyles.Cell
    
    // MARK: Init
    
    public init(
        sheetTitleFont: CourierStyles.Font = CourierStyles.Font(
            font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
            color: .label
        ),
        sheetSettingStyles: CourierStyles.Preferences.SettingStyles = CourierStyles.Preferences.SettingStyles(),
        sheetCornerRadius: CGFloat = Theme.Preferences.sheetCornerRadius,
        sheetCellStyles: CourierStyles.Cell = CourierStyles.Cell()
    ) {
        self.sheetTitleFont = sheetTitleFont
        self.sheetSettingStyles = sheetSettingStyles
        self.sheetCornerRadius = sheetCornerRadius
        self.sheetCellStyles = sheetCellStyles
    }
    
    // MARK: Defaults
    
    @objc public static let defaultDark = CourierPreferencesTheme()
    @objc public static let defaultLight = CourierPreferencesTheme()
    
}
