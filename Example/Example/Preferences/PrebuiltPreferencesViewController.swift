//
//  PrebuiltPreferencesViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/11/24.
//

import UIKit
import Courier_iOS

class PrebuiltPreferencesViewController: UIViewController {
    
    private let mode: CourierPreferences.Mode
    
    init(mode: CourierPreferences.Mode = .channels(CourierUserPreferencesChannel.allCases)) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var courierPreferences = {
        return CourierPreferences(
            mode: self.mode,
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
