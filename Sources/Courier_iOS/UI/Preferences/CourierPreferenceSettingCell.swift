//
//  CourierPreferenceCell.swift
//
//
//  Created by https://github.com/mikemilla on 2/28/24.
//

import UIKit

internal class CourierPreferenceSettingCell: UITableViewCell {
    
    static let id = "CourierPreferenceSettingCell"
    
    private var item: CourierSheetItem? = nil
    
    let itemLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private var onToggle: ((Bool) -> Void)? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        toggleSwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(itemLabel)
        contentView.addSubview(toggleSwitch)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.margin),
            itemLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.margin),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configureCell(item: CourierSheetItem, onToggle: @escaping (Bool) -> Void) {
        
        self.item = item
        
        self.itemLabel.text = item.title
        self.toggleSwitch.isOn = item.isOn
        self.toggleSwitch.isEnabled = !item.isDisabled
        
        self.contentView.isUserInteractionEnabled = !item.isDisabled
        
        self.onToggle = onToggle
        
    }
    
    func setTheme(theme: CourierPreferencesTheme) {
        self.itemLabel.font = theme.sheetSettingStyles.font?.font
        self.itemLabel.textColor = theme.sheetSettingStyles.font?.color
        self.toggleSwitch.onTintColor = theme.sheetSettingStyles.toggleColor
        self.selectionStyle = theme.sheetCellStyles.selectionStyle
    }
    
    internal func toggle() {
        
        // Get the item
        if let item = self.item {
            
            if (item.isDisabled) {
                return
            }
            
            // Toggle the item
            toggleSwitch.setOn(!toggleSwitch.isOn, animated: true)
            switchToggled(toggleSwitch)
            
        }
        
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        self.onToggle?(sender.isOn)
    }
    
}
