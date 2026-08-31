//
//  UITestsAuthViewController.swift
//
//  Minimal sign-in screen used by the e2e suite. Exposes the two
//  accessibility identifiers the Behave login flow requires:
//
//    - usernameInput  (UITextField for the user id)
//    - signInButton   (UIButton that signs in via Courier.shared.signIn)
//
//  After successful sign-in we push UITestsComponentsViewController, which
//  hosts the inboxButton / pushNotificationsButton / preferencesButton /
//  signOutButton expected by the rest of the test suite.
//

import UIKit
import Courier_iOS

final class UITestsAuthViewController: UIViewController {

    private let usernameInput = UITextField()
    private let signInButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let errorLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Sign In"

        usernameInput.accessibilityIdentifier = "usernameInput"
        usernameInput.placeholder = "Enter user id"
        usernameInput.borderStyle = .roundedRect
        usernameInput.autocapitalizationType = .none
        usernameInput.autocorrectionType = .no
        usernameInput.translatesAutoresizingMaskIntoConstraints = false

        signInButton.accessibilityIdentifier = "signInButton"
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)

        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        errorLabel.accessibilityIdentifier = "authErrorLabel"
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 13)
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(usernameInput)
        view.addSubview(signInButton)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)

        NSLayoutConstraint.activate([
            usernameInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            usernameInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            usernameInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            usernameInput.heightAnchor.constraint(equalToConstant: 44),

            signInButton.topAnchor.constraint(equalTo: usernameInput.bottomAnchor, constant: 16),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 44),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 16),

            errorLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }

    @objc private func signInTapped() {
        let userId = usernameInput.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !userId.isEmpty else {
            errorLabel.text = "User id is required"
            return
        }
        Task { @MainActor in
            await performSignIn(userId: userId)
        }
    }

    private func performSignIn(userId: String) async {
        setBusy(true)
        errorLabel.text = nil

        if await Courier.shared.userId != nil {
            await Courier.shared.signOut()
        }

        let authKey = Env.COURIER_AUTH_KEY
        let baseUrl = "https://api.courier.com"

        do {
            let jwt = try await ExampleServer().generateJwt(
                baseUrl: baseUrl,
                authKey: authKey,
                userId: userId
            )
            await Courier.shared.signIn(
                userId: userId,
                accessToken: jwt
            )
            setBusy(false)
            let components = UITestsComponentsViewController()
            navigationController?.pushViewController(components, animated: false)
        } catch {
            setBusy(false)
            errorLabel.text = "Sign in failed: \(error)"
        }
    }

    private func setBusy(_ busy: Bool) {
        signInButton.isEnabled = !busy
        usernameInput.isEnabled = !busy
        if busy { activityIndicator.startAnimating() } else { activityIndicator.stopAnimating() }
    }
}
