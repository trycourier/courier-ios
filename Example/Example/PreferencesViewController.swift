//
//  PreferencesViewController.swift
//  Example
//
//  Created by Michael Miller on 1/9/24.
//

import UIKit
import Courier_iOS

class PreferencesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    private let textColor = UIColor(red: 42 / 255, green: 21 / 255, blue: 55 / 255, alpha: 100)
    private let secondaryColor = UIColor(red: 234 / 255, green: 104 / 255, blue: 102 / 255, alpha: 100)
    
    private lazy var courierPreferences = {
        return CourierPreferences(
            availableChannels: [.push, .sms, .email],
            lightTheme: CourierPreferencesTheme(
                loadingIndicatorColor: secondaryColor,
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
                )
            )
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Preferences"
        
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
