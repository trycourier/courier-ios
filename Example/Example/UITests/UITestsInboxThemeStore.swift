//
//  UITestsInboxThemeStore.swift
//
//  Shared in-memory state behind UITestsInboxViewController and
//  UITestsEditInboxThemeViewController. The Behave suite only exercises
//  `allFontSizeInput` via `change_all_font(value)` — every other input the
//  edit screen displays is captured here as a string for accessibility
//  parity but not all values are applied to the theme.
//
//  When the user saves an edit we post `.uiTestsInboxThemeDidChange` so the
//  hosted CourierInbox can rebuild with the new theme.
//

import UIKit
import Courier_iOS

final class UITestsInboxThemeStore {

    static let shared = UITestsInboxThemeStore()

    private(set) var allFontSize: CGFloat = 14
    private(set) var fontName: String = "Helvetica"
    private(set) var fontColor: UIColor = .black

    func setAllFontSize(_ size: CGFloat) {
        allFontSize = size
        NotificationCenter.default.post(name: .uiTestsInboxThemeDidChange, object: nil)
    }

    func makeTheme() -> CourierInboxTheme {
        let bodyFont = UIFont(name: fontName, size: allFontSize) ?? .systemFont(ofSize: allFontSize)
        let titleFont = UIFont(name: fontName, size: allFontSize) ?? .systemFont(ofSize: allFontSize)
        let timeFont = UIFont(name: fontName, size: allFontSize) ?? .systemFont(ofSize: allFontSize)
        let buttonFont = UIFont(name: fontName, size: allFontSize) ?? .systemFont(ofSize: allFontSize)

        return CourierInboxTheme(
            titleStyle: CourierStyles.Inbox.TextStyle(
                unread: CourierStyles.Font(font: titleFont, color: fontColor),
                read: CourierStyles.Font(font: titleFont, color: fontColor)
            ),
            timeStyle: CourierStyles.Inbox.TextStyle(
                unread: CourierStyles.Font(font: timeFont, color: fontColor),
                read: CourierStyles.Font(font: timeFont, color: fontColor)
            ),
            bodyStyle: CourierStyles.Inbox.TextStyle(
                unread: CourierStyles.Font(font: bodyFont, color: fontColor),
                read: CourierStyles.Font(font: bodyFont, color: fontColor)
            ),
            buttonStyle: CourierStyles.Inbox.ButtonStyle(
                unread: CourierStyles.Button(font: CourierStyles.Font(font: buttonFont, color: fontColor)),
                read: CourierStyles.Button(font: CourierStyles.Font(font: buttonFont, color: fontColor))
            )
        )
    }
}
