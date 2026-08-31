//
//  UITestsEditInboxThemeViewController.swift
//
//  Inbox-theme editor used by the Behave `edit_screen.py` steps. Exposes a
//  row per supported input with `accessibilityIdentifier = "<kind>Input"`.
//  Tapping a row's text field makes it first responder so Appium's
//  `send_keys` can type into it; tapping the nav-bar "Save" applies the
//  changes through `UITestsInboxThemeStore` and pops back to the inbox.
//

import UIKit

private enum EditableField: String, CaseIterable {
    case allFontSize = "allFontSize"
    case tabIndicatorColor
    case tabSelectedFontName
    case tabSelectedFontColor
    case tabSelectedIndicatorFontName
    case tabSelectedIndicatorFontColor
    case tabSelectedIndicatorColor
    case tabUnselectedFontName
    case tabUnselectedFontColor
    case tabUnselectedIndicatorFontName
    case tabUnselectedIndicatorFontColor
    case tabUnselectedIndicatorColor
    case readingSwipeActionReadIcon
    case readingSwipeActionReadColor
    case readingSwipeActionUnreadIcon
    case readingSwipeActionUnreadColor
    case archivingSwipeActionArchiveIcon
    case archivingSwipeActionArchiveColor
    case unreadIndicatorStyle
    case unreadIndicatorColor
    case titleStyleUnreadFontName
    case titleStyleUnreadFontColor
    case timeStyleUnreadFontName
    case timeStyleUnreadFontColor
    case timeStyleReadFontName
    case timeStyleReadFontColor

    var accessibilityID: String { "\(rawValue)Input" }
}

final class UITestsEditInboxThemeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var values: [EditableField: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Edit Inbox"
        navigationItem.hidesBackButton = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        // Seed the editor with the current theme's all-font-size so re-opens
        // show the active value.
        values[.allFontSize] = String(format: "%g", UITestsInboxThemeStore.shared.allFontSize)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EditableRowCell.self, forCellReuseIdentifier: EditableRowCell.id)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        applyChanges()
        navigationController?.popViewController(animated: false)
    }

    @objc private func closeTapped() {
        view.endEditing(true)
        navigationController?.popViewController(animated: false)
    }

    private func applyChanges() {
        if let raw = values[.allFontSize], let size = Double(raw) {
            UITestsInboxThemeStore.shared.setAllFontSize(CGFloat(size))
        }
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        EditableField.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditableRowCell.id, for: indexPath) as! EditableRowCell
        let field = EditableField.allCases[indexPath.row]
        cell.configure(
            title: field.rawValue,
            value: values[field] ?? "",
            inputAccessibilityID: field.accessibilityID
        ) { [weak self] newValue in
            self?.values[field] = newValue
        }
        return cell
    }
}

private final class EditableRowCell: UITableViewCell, UITextFieldDelegate {

    static let id = "EditableRowCell"

    private let titleLabel = UILabel()
    let inputField = UITextField()
    private var onChange: ((String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        inputField.borderStyle = .roundedRect
        inputField.autocapitalizationType = .none
        inputField.autocorrectionType = .no
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        contentView.addSubview(titleLabel)
        contentView.addSubview(inputField)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            inputField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            inputField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            inputField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            inputField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            inputField.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    required init?(coder: NSCoder) { fatalError("unused") }

    func configure(title: String, value: String, inputAccessibilityID: String, onChange: @escaping (String) -> Void) {
        titleLabel.text = title
        titleLabel.accessibilityIdentifier = "\(title)Label"
        inputField.text = value
        inputField.accessibilityIdentifier = inputAccessibilityID
        self.onChange = onChange
    }

    @objc private func textChanged() {
        onChange?(inputField.text ?? "")
    }
}
