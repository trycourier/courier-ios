//
//  CourierPreferenceSheet.swift
//
//
//  Created by https://github.com/mikemilla on 2/26/24.
//

import UIKit

internal struct CourierSheetItem {
    let title: String
    var isOn: Bool
    let isDisabled: Bool
    let data: Any?
}

@available(iOS 15.0, *)
internal class CourierPreferencesSheet: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CourierPreferenceSettingCell.self, forCellReuseIdentifier: CourierPreferenceSettingCell.id)
        return tableView
    }()
    
    lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        return navBar
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var theme: CourierPreferencesTheme
    private let title: String
    private let onSheetClose: () -> Void
    
    init(theme: CourierPreferencesTheme, title: String, onSheetClose: @escaping () -> Void) {
        self.theme = theme
        self.title = title
        self.onSheetClose = onSheetClose
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        self.theme = CourierPreferencesTheme()
        self.title = "Topic"
        self.onSheetClose = {}
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.theme = CourierPreferencesTheme()
        self.title = "Topic"
        self.onSheetClose = {}
        super.init(coder: coder)
        setup()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    private func setup() {
        addTitleBar()
        addTableView()
        reloadViews()
    }
    
    func setTheme(theme: CourierPreferencesTheme) {
        self.theme = theme
        self.reloadViews()
    }
    
    private func reloadViews() {
        
        // Update navbar
        navigationBar.titleTextAttributes = [
            .font: self.theme.sheetTitleFont.font,
            .foregroundColor: self.theme.sheetTitleFont.color
        ]
        
        // Update all cells
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? CourierPreferenceSettingCell {
                cell.setTheme(theme: self.theme)
            }
        }
        
        // Table theme
        tableView.separatorStyle = self.theme.sheetCellStyles.separatorStyle
        tableView.separatorInset = self.theme.sheetCellStyles.separatorInsets
        tableView.separatorColor = self.theme.sheetCellStyles.separatorColor
        
    }
    
    private func addTitleBar() {
        
        // Add the bar
        addSubview(navigationBar)

        // Title
        let navItem = UINavigationItem(title: title)
        
        // Close button
        let closeButton = UIButton(type: .close)
        closeButton.addTarget(self, action: #selector(closeButtonClick), for: .touchUpInside)
        let closeBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        // Add items
        navItem.rightBarButtonItem = closeBarButtonItem
        navigationBar.items = [navItem]
        
        // Position the nav bar
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor, constant: Theme.margin / 2),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    @objc private func closeButtonClick() {
        onSheetClose()
    }
    
    private func addTableView() {
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Theme.margin),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PreferencesSheetViewController.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CourierPreferenceSettingCell.id, for: indexPath) as! CourierPreferenceSettingCell

        cell.configureCell(
            item: PreferencesSheetViewController.items[indexPath.row],
            onToggle: { isOn in
                PreferencesSheetViewController.items[indexPath.row].isOn = isOn
            }
        )
        
        cell.setTheme(theme: self.theme)

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Toggle the cell
        if let cell = tableView.cellForRow(at: indexPath) as? CourierPreferenceSettingCell {
            cell.toggle()
        }
        
        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.Preferences.settingsCellHeight
    }
    
}
