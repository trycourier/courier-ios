//
//  UITestsPreferencesViewController.swift
//
//  Minimal preferences shell. The iOS UIKit scenarios in smoke.feature don't
//  exercise preferences deeply — this VC just satisfies the navigation
//  contract (`preferencesButton` push target) and hosts CourierPreferences
//  with a Close button for symmetry with the other UITests screens.
//

import UIKit
import Courier_iOS

final class UITestsPreferencesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Preferences"
        navigationItem.hidesBackButton = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        let preferences = CourierPreferences(
            mode: .channels(CourierUserPreferencesChannel.allCases),
            lightTheme: .defaultLight,
            darkTheme: .defaultDark
        )
        preferences.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(preferences)
        NSLayoutConstraint.activate([
            preferences.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            preferences.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            preferences.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            preferences.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: false)
    }
}
