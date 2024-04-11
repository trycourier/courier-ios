//
//  CourierPreferencesTheme.swift
//
//
//  Created by https://github.com/mikemilla on 3/5/24.
//

import UIKit

@objc public class CourierPreferencesTheme: NSObject {
    
    // MARK: Styling
    
    let brandId: String?
    let loadingIndicatorColor: UIColor?
    let topicCellStyles: CourierStyles.Cell
    let sectionTitleFont: CourierStyles.Font
    let topicTitleFont: CourierStyles.Font
    let topicSubtitleFont: CourierStyles.Font
    let topicButton: CourierStyles.Button
    let sheetTitleFont: CourierStyles.Font
    let sheetSettingStyles: CourierStyles.Preferences.SettingStyles
    let sheetCornerRadius: CGFloat
    let sheetCellStyles: CourierStyles.Cell
    let infoViewStyle: CourierStyles.InfoViewStyle
    
    // MARK: Init
    
    public init(
        brandId: String? = nil,
        loadingIndicatorColor: UIColor? = nil,
        sectionTitleFont: CourierStyles.Font = CourierStyles.Font(
            font: UIFont.boldSystemFont(ofSize: Theme.Preferences.sectionTitleFontSize),
            color: .label
        ),
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
        sheetCellStyles: CourierStyles.Cell = CourierStyles.Cell(),
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
        self.loadingIndicatorColor = loadingIndicatorColor
        self.topicCellStyles = topicCellStyles
        self.sectionTitleFont = sectionTitleFont
        self.topicTitleFont = topicTitleFont
        self.topicSubtitleFont = topicSubtitleFont
        self.topicButton = topicButton
        self.sheetTitleFont = sheetTitleFont
        self.sheetSettingStyles = sheetSettingStyles
        self.sheetCornerRadius = sheetCornerRadius
        self.sheetCellStyles = sheetCellStyles
        self.infoViewStyle = infoViewStyle
    }
    
    // MARK: Defaults
    
    @objc public static let defaultDark = CourierPreferencesTheme()
    @objc public static let defaultLight = CourierPreferencesTheme()
    
    // MARK: Brand
    
    internal var brand: CourierBrand? = nil
    
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
    
}
