//
//  UITestsComponentsViewController.swift
//
//  Post-login hub. Hosts the four navigation buttons the Behave suite drives:
//
//    - inboxButton
//    - pushNotificationsButton
//    - preferencesButton
//    - signOutButton
//

import UIKit
import Courier_iOS

final class UITestsComponentsViewController: UIViewController {

    private lazy var inboxButton = makeButton(title: "Inbox", id: "inboxButton", action: #selector(openInbox))
    private lazy var pushButton = makeButton(title: "Push Notifications", id: "pushNotificationsButton", action: #selector(openPush))
    private lazy var preferencesButton = makeButton(title: "Preferences", id: "preferencesButton", action: #selector(openPreferences))
    private lazy var signOutButton = makeButton(title: "Sign Out", id: "signOutButton", action: #selector(signOut))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Components"
        navigationItem.hidesBackButton = true

        let stack = UIStackView(arrangedSubviews: [
            inboxButton, pushButton, preferencesButton, signOutButton,
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
        ])
    }

    private func makeButton(title: String, id: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.accessibilityIdentifier = id
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func openInbox() {
        navigationController?.pushViewController(UITestsInboxViewController(), animated: false)
    }

    @objc private func openPush() {
        navigationController?.pushViewController(UITestsPushViewController(), animated: false)
    }

    @objc private func openPreferences() {
        navigationController?.pushViewController(UITestsPreferencesViewController(), animated: false)
    }

    @objc private func signOut() {
        Task { @MainActor in
            await Courier.shared.signOut()
            navigationController?.popToRootViewController(animated: false)
        }
    }
}
