//
//  EditValueViewController.swift
//  Example
//
//  Created by Michael Miller on 11/3/26.
//

import UIKit

// A small sheet for editing one value, in place of a text field inside an alert
class EditValueViewController: UIViewController, UITextFieldDelegate {

    private let initialValue: String
    private let onSave: (String) -> Void

    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        textField.adjustsFontForContentSizeCategory = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.clearButtonMode = .always
        textField.returnKeyType = .done
        return textField
    }()

    private let fieldBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        return view
    }()

    init(title: String, value: String, onSave: @escaping (String) -> Void) {
        self.initialValue = value
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func present(from presenter: UIViewController, title: String, value: String, onSave: @escaping (String) -> Void) {
        let navigationController = UINavigationController(
            rootViewController: EditValueViewController(title: title, value: value, onSave: onSave)
        )
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.custom { _ in 160 }]
            sheet.prefersGrabberVisible = true
        }
        presenter.present(navigationController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground

        textField.text = initialValue
        textField.placeholder = title
        textField.accessibilityLabel = title
        textField.delegate = self

        view.addSubview(fieldBackground)
        fieldBackground.addSubview(textField)

        NSLayoutConstraint.activate([
            fieldBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            fieldBackground.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            fieldBackground.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            textField.topAnchor.constraint(equalTo: fieldBackground.topAnchor, constant: 14),
            textField.bottomAnchor.constraint(equalTo: fieldBackground.bottomAnchor, constant: -14),
            textField.leadingAnchor.constraint(equalTo: fieldBackground.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: fieldBackground.trailingAnchor, constant: -8)
        ])

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in
                self?.save()
            }
        )

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        save()
        return true
    }

    private func save() {
        onSave(textField.text ?? "")
        dismiss(animated: true)
    }

}
