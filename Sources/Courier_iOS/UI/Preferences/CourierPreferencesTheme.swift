//
//  CourierPreferencesTheme.swift
//
//
//  Created by https://github.com/mikemilla on 3/5/24.
//

import UIKit

@objc public class CourierPreferencesTheme: NSObject {
    
    // MARK: Styling
    
    private let loadingIndicatorColor: UIColor?
    internal let topicCellStyles: CourierStyles.Cell
    internal let topicTitleFont: CourierStyles.Font
    internal let topicSubtitleFont: CourierStyles.Font
    internal let topicButton: CourierStyles.Button
    internal let sheetTitleFont: CourierStyles.Font
    internal let sheetSettingStyles: CourierStyles.Preferences.SettingStyles
    internal let sheetCornerRadius: CGFloat
    internal let sheetCellStyles: CourierStyles.Cell
    
    // MARK: Init
    
    public init(
        loadingIndicatorColor: UIColor? = nil,
        topicCellStyles: CourierStyles.Cell = CourierStyles.Cell(),
        topicTitleFont: CourierStyles.Font = CourierStyles.Font(
            font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
            color: .label
        ),
        topicSubtitleFont: CourierStyles.Font = CourierStyles.Font(
            font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
            color: .label
        ),
        topicButton: CourierStyles.Button = CourierStyles.Button(
            font: CourierStyles.Font(font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize), color: .label),
            backgroundColor: .secondarySystemBackground,
            cornerRadius: Theme.Preferences.actionButtonCornerRadius
        ),
        sheetTitleFont: CourierStyles.Font = CourierStyles.Font(
            font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
            color: .label
        ),
        sheetSettingStyles: CourierStyles.Preferences.SettingStyles = CourierStyles.Preferences.SettingStyles(),
        sheetCornerRadius: CGFloat = Theme.Preferences.sheetCornerRadius,
        sheetCellStyles: CourierStyles.Cell = CourierStyles.Cell()
    ) {
        self.loadingIndicatorColor = loadingIndicatorColor
        self.topicCellStyles = topicCellStyles
        self.topicTitleFont = topicTitleFont
        self.topicSubtitleFont = topicSubtitleFont
        self.topicButton = topicButton
        self.sheetTitleFont = sheetTitleFont
        self.sheetSettingStyles = sheetSettingStyles
        self.sheetCornerRadius = sheetCornerRadius
        self.sheetCellStyles = sheetCellStyles
    }
    
    // MARK: Defaults
    
    @objc public static let defaultDark = CourierPreferencesTheme()
    @objc public static let defaultLight = CourierPreferencesTheme()
    
}
