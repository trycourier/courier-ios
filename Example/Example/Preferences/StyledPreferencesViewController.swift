//
//  StyledPreferencesViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/11/24.
//

import UIKit
import Courier_iOS

class StyledPreferencesViewController: UIViewController {

    private lazy var courierPreferences = {
        return CourierPreferences(
            mode: .channels([.push, .sms, .email]),
            lightTheme: makeTheme(.light),
            darkTheme: makeTheme(.dark),
            onError: { error in
                self.showCode(title: "Preferences Error", code: error.localizedDescription)
                return error.localizedDescription
            }
        )
    }()
    
    // The background stays the system one, so the topic sheet keeps its Liquid Glass look on iOS 26
    private func makeTheme(_ palette: StyledPalette) -> CourierPreferencesTheme {
        return CourierPreferencesTheme(
            brandId: Env.COURIER_BRAND_ID,
            loadingIndicatorColor: palette.accent,
            sectionTitleFont: CourierStyles.Font(font: StyledFont.black(20), color: palette.text),
            topicCellStyles: CourierStyles.Cell(
                separatorStyle: .singleLine,
                separatorColor: palette.separator
            ),
            topicTitleFont: CourierStyles.Font(font: StyledFont.heavy(17), color: palette.text),
            topicSubtitleFont: CourierStyles.Font(font: StyledFont.medium(15), color: palette.secondaryText),
            topicButton: CourierStyles.Button(
                font: CourierStyles.Font(font: StyledFont.heavy(15), color: palette.accent),
                backgroundColor: palette.accentSoft,
                cornerRadius: 100
            ),
            sheetTitleFont: CourierStyles.Font(font: StyledFont.heavy(17), color: palette.text),
            sheetSettingStyles: CourierStyles.Preferences.SettingStyles(
                font: CourierStyles.Font(font: StyledFont.medium(17), color: palette.text),
                toggleColor: palette.accent
            ),
            sheetCellStyles: CourierStyles.Cell(
                separatorStyle: .singleLine,
                separatorColor: palette.separator
            ),
            infoViewStyle: CourierStyles.InfoViewStyle(
                font: CourierStyles.Font(font: StyledFont.medium(18), color: palette.secondaryText),
                button: CourierStyles.Button(
                    font: CourierStyles.Font(font: StyledFont.heavy(15), color: palette.onAccent),
                    backgroundColor: palette.accent,
                    cornerRadius: 100
                )
            )
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        courierPreferences.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(courierPreferences)

        NSLayoutConstraint.activate([
            courierPreferences.topAnchor.constraint(equalTo: view.topAnchor),
            courierPreferences.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            courierPreferences.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            courierPreferences.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

    }

}
