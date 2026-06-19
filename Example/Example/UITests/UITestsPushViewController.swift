//
//  UITestsPushViewController.swift
//
//  Push-notifications screen used by smoke_push.feature. The only selector
//  the Behave suite drives is the "Request permission" button (matched by
//  the button's title via accessibility lookup). The notification UI shown
//  after a Courier /send call is rendered by iOS itself.
//

import UIKit
import Courier_iOS

final class UITestsPushViewController: UIViewController {

    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Push Notifications"
        navigationItem.hidesBackButton = true

        let requestButton = UIButton(type: .system)
        requestButton.setTitle("Request permission", for: .normal)
        requestButton.accessibilityIdentifier = "requestNotificationPermissionButton"
        requestButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        requestButton.addTarget(self, action: #selector(requestPermission), for: .touchUpInside)
        requestButton.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.accessibilityIdentifier = "notificationPermissionStatusLabel"
        statusLabel.text = "Status:"
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        let closeButton = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.leftBarButtonItem = closeButton

        view.addSubview(requestButton)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            requestButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            requestButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statusLabel.topAnchor.constraint(equalTo: requestButton.bottomAnchor, constant: 24),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc private func requestPermission() {
        Task { @MainActor in
            do {
                let status = try await Courier.requestNotificationPermission()
                statusLabel.text = "Status: \(status.rawValue)"
            } catch {
                statusLabel.text = "Status: error"
            }
        }
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: false)
    }
}
