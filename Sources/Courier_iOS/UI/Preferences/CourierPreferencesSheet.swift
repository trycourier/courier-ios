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
@available(iOSApplicationExtension, unavailable)
internal class CourierPreferencesSheet: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CourierPreferenceSettingCell.self, forCellReuseIdentifier: CourierPreferenceSettingCell.id)
        return tableView
    }()
    
    private var theme: CourierPreferencesTheme
    
    init(theme: CourierPreferencesTheme) {
        self.theme = theme
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        self.theme = CourierPreferencesTheme()
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.theme = CourierPreferencesTheme()
        super.init(coder: coder)
        setup()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    private func setup() {
        addTableView()
        reloadViews()
    }
    
    func setTheme(theme: CourierPreferencesTheme) {
        self.theme = theme
        self.reloadViews()
    }
    
    private func reloadViews() {
        
        // Background
        tableView.backgroundColor = self.theme.sheetBackgroundColor
        
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


        tableView.appendAccessibilityIdentifier("PreferencesTableView")
    }
    
    private func addTableView() {
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
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
        cell.backgroundColor = .clear
        
        // Like the system lists, separators go between rows and not under the last one
        let isLastRow = indexPath.row == PreferencesSheetViewController.items.count - 1
        cell.separatorInset = isLastRow ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude) : tableView.separatorInset

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
