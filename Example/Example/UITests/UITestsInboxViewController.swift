//
//  UITestsInboxViewController.swift
//
//  Hosts a CourierInbox configured with deterministic Helvetica/black styles
//  so the Behave `validate_style` checks have a known baseline. Nav bar
//  exposes:
//
//    - "Edit" button — pushes UITestsEditInboxThemeViewController
//    - "Close" button — pops back to the components hub
//

import UIKit
import Courier_iOS

final class UITestsInboxViewController: UIViewController {

    private var inbox: CourierInbox?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Inbox"
        navigationItem.hidesBackButton = true

        // Force light appearance so #000000 / #ffffff are deterministic for the
        // accessibility-identifier validation the Behave suite performs.
        overrideUserInterfaceStyle = .light

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        rebuildInbox()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .uiTestsInboxThemeDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        rebuildInbox()
    }

    private func rebuildInbox() {
        inbox?.removeFromSuperview()

        let theme = UITestsInboxThemeStore.shared.makeTheme()
        let inbox = CourierInbox(
            lightTheme: theme,
            darkTheme: theme,
            didClickInboxMessageAtIndex: nil,
            didClickInboxActionForMessageAtIndex: nil,
            didScrollInbox: nil
        )
        inbox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inbox)
        NSLayoutConstraint.activate([
            inbox.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            inbox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inbox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inbox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        self.inbox = inbox
    }

    @objc private func editTapped() {
        navigationController?.pushViewController(UITestsEditInboxThemeViewController(), animated: false)
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: false)
    }
}

extension Notification.Name {
    static let uiTestsInboxThemeDidChange = Notification.Name("uiTestsInboxThemeDidChange")
}
