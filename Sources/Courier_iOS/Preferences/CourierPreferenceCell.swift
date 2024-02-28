//
//  CourierPreferenceCell.swift
//
//
//  Created by https://github.com/mikemilla on 2/28/24.
//

import UIKit

internal class CourierPreferenceCell: UITableViewCell {
    
    static let id = "CourierPreferenceCell"
    
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
            itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configureCell(item: CourierSheetItem, onToggle: @escaping (Bool) -> Void) {
        
        self.itemLabel.text = item.title
        self.onToggle = onToggle
        
//        // If required, users cannot change this
//        if (topic.status == .required) {
//            toggleSwitch.isOn = true
//            toggleSwitch.isEnabled = false
//            toggleSwitch.isUserInteractionEnabled = false
//            return
//        }
//        
//        // If opted out, disable all toggles
//        if (topic.status == .optedOut) {
//            toggleSwitch.isOn = false
//            return
//        }
//        
//        // Enable all as the fallback
//        if (topic.customRouting.isEmpty) {
//            toggleSwitch.isOn = true
//            return
//        }
        
        // Apply custom settings
//        let isToggled = topic.customRouting.contains { $0.rawValue == channel.rawValue }
        toggleSwitch.isOn = item.isOn
        
    }
    
    internal func toggle() {
        toggleSwitch.setOn(!toggleSwitch.isOn, animated: true)
        switchToggled(toggleSwitch)
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        self.onToggle?(sender.isOn)
    }
    
}
