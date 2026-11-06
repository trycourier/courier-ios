//
//  ThemeDefaultsUnitTests.swift
//  Courier_iOS
//

import UIKit
import XCTest
@testable import Courier_iOS

class ThemeDefaultsUnitTests: XCTestCase {

    private func luminance(_ color: UIColor) -> CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        func channel(_ v: CGFloat) -> CGFloat { v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
        return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
    }

    private func contrast(_ a: UIColor, _ b: UIColor) -> CGFloat {
        let (high, low) = (max(luminance(a), luminance(b)), min(luminance(a), luminance(b)))
        return (high + 0.05) / (low + 0.05)
    }

    private func resolved(_ color: UIColor, _ style: UIUserInterfaceStyle) -> UIColor {
        color.resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
    }

    // The unselected tab's count is drawn in .label on this fill. WCAG asks for 4.5:1 for text this size.
    func testUnselectedCountIsReadableInBothAppearances() {
        let theme = CourierInboxTheme()
        let fill = theme.getUnreadCountColor(isSelected: false)!
        let text = theme.tabStyle.unselected.indicator.font.color
        for style in [UIUserInterfaceStyle.light, .dark] {
            XCTAssertGreaterThanOrEqual(contrast(resolved(fill, style), resolved(text, style)), 4.5, "\(style.rawValue)")
        }
    }

    func testUnselectedCountKeepsItsLightAppearance() {
        let fill = CourierInboxTheme().getUnreadCountColor(isSelected: false)!
        XCTAssertEqual(resolved(fill, .light), resolved(.lightGray, .light))
    }

    func testCustomUnselectedCountColorStillWins() {
        let theme = CourierInboxTheme(
            tabStyle: CourierStyles.Inbox.TabStyle(
                selected: CourierInboxTheme().tabStyle.selected,
                unselected: CourierStyles.Inbox.TabItemStyle(
                    font: CourierInboxTheme().tabStyle.unselected.font,
                    indicator: CourierStyles.Inbox.TabIndicatorStyle(
                        font: CourierInboxTheme().tabStyle.unselected.indicator.font,
                        color: .systemPink
                    )
                )
            )
        )
        XCTAssertEqual(theme.getUnreadCountColor(isSelected: false), .systemPink)
    }

    func testTopicSubtitleIsSecondaryByDefault() {
        XCTAssertEqual(CourierPreferencesTheme().topicSubtitleFont.color, .secondaryLabel)
    }

}
