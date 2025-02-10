//
//  BrandedPreferencesViewController.swift
//  Example
//
//  Created by Michael Miller on 2/10/25.
//

import UIKit
import Courier_iOS

class BrandedPreferencesViewController: UIViewController {
    
    private let theme = CourierPreferencesTheme(
        brandId: Env.COURIER_BRAND_ID
    )

    private lazy var courierPreferences = {
        return CourierPreferences(
            lightTheme: theme,
            darkTheme: theme,
            onError: { error in
                self.showCodeAlert(title: "Preferences Error", code: error.localizedDescription)
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

