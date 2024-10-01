//
//  PrebuiltPreferencesViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/11/24.
//

import UIKit
import Courier_iOS

class PrebuiltPreferencesViewController: UIViewController {
    
    private lazy var courierPreferences = {
        return CourierPreferences(
            mode: .topic,
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
