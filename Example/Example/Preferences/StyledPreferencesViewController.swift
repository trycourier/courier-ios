//
//  StyledPreferencesViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/11/24.
//

import UIKit
import Courier_iOS

class StyledPreferencesViewController: UIViewController {

    private let textColor = UIColor(red: 42 / 255, green: 21 / 255, blue: 55 / 255, alpha: 100)
    private let secondaryColor = UIColor(red: 234 / 255, green: 104 / 255, blue: 102 / 255, alpha: 100)

    private lazy var courierPreferences = {
        return CourierPreferences(
            mode: .channels([.push, .sms, .email]),
            lightTheme: CourierPreferencesTheme(
                brandId: Env.COURIER_BRAND_ID,
                sectionTitleFont: CourierStyles.Font(
                    font: UIFont(name: "Avenir Black", size: 20)!,
                    color: textColor
                ),
                topicCellStyles: CourierStyles.Cell(
                    separatorStyle: .none
                ),
                topicTitleFont: CourierStyles.Font(
                    font: UIFont(name: "Avenir Medium", size: 18)!,
                    color: textColor
                ),
                topicSubtitleFont: CourierStyles.Font(
                    font: UIFont(name: "Avenir Medium", size: 16)!,
                    color: .gray
                ),
                topicButton: CourierStyles.Button(
                    font: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 16)!,
                        color: .white
                    ),
                    backgroundColor: secondaryColor,
                    cornerRadius: 8
                ),
                sheetTitleFont: CourierStyles.Font(
                    font: UIFont(name: "Avenir Medium", size: 18)!,
                    color: textColor
                ),
                sheetSettingStyles: CourierStyles.Preferences.SettingStyles(
                    font: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: textColor
                    ),
                    toggleColor: secondaryColor
                ),
                sheetCornerRadius: 0,
                sheetCellStyles: CourierStyles.Cell(
                    separatorStyle: .none
                ),
                infoViewStyle: CourierStyles.InfoViewStyle(
                    font: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 20)!,
                        color: textColor
                    ),
                    button: CourierStyles.Button(
                        font: CourierStyles.Font(
                            font: UIFont(name: "Avenir Medium", size: 16)!,
                            color: .white
                        ),
                        backgroundColor: secondaryColor,
                        cornerRadius: 8
                    )
                )
            ),
            darkTheme: CourierPreferencesTheme(
                brandId: Env.COURIER_BRAND_ID,
                loadingIndicatorColor: secondaryColor,
                sectionTitleFont: CourierStyles.Font(
                    font: UIFont(name: "Avenir Black", size: 20)!,
                    color: .white
                ),
                topicCellStyles: CourierStyles.Cell(
                    separatorStyle: .none
                ),
                topicTitleFont: CourierStyles.Font(
                    font: UIFont(name: "Avenir Medium", size: 18)!,
                    color: .white
                ),
                topicSubtitleFont: CourierStyles.Font(
                    font: UIFont(name: "Avenir Medium", size: 16)!,
                    color: .white
                ),
                topicButton: CourierStyles.Button(
                    font: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 16)!,
                        color: .white
                    ),
                    backgroundColor: secondaryColor,
                    cornerRadius: 8
                ),
                sheetTitleFont: CourierStyles.Font(
                    font: UIFont(name: "Avenir Medium", size: 18)!,
                    color: .white
                ),
                sheetSettingStyles: CourierStyles.Preferences.SettingStyles(
                    font: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: .white
                    ),
                    toggleColor: secondaryColor
                ),
                sheetCornerRadius: 0,
                sheetCellStyles: CourierStyles.Cell(
                    separatorStyle: .none
                ),
                infoViewStyle: CourierStyles.InfoViewStyle(
                    font: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 20)!,
                        color: .white
                    ),
                    button: CourierStyles.Button(
                        font: CourierStyles.Font(
                            font: UIFont(name: "Avenir Medium", size: 16)!,
                            color: .white
                        ),
                        backgroundColor: secondaryColor,
                        cornerRadius: 8
                    )
                )
            ),
            onError: { error in
                self.showCodeAlert(title: "Preferences Error", code: error.localizedDescription)
                return error.localizedDescription
            }
        )
    }()
    
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
