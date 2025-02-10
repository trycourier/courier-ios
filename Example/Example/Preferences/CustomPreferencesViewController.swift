//
//  CustomPreferencesViewController.swift
//  Example
//
//  Created by Michael Miller on 2/10/25.
//

import UIKit
import Courier_iOS

class CustomPreferencesViewController: UIViewController {
    
    private lazy var courierPreferences = {
        return CourierPreferences(
            custom
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
