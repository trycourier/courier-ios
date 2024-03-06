//
//  CourierPreferenceTopicCell.swift
//  
//
//  Created by https://github.com/mikemilla on 2/28/24.
//

import UIKit

internal class CourierPreferenceTopicCell: UITableViewCell {
    
    static let id = "CourierPreferenceTopicCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(editButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.margin),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.margin),
            titleLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -Theme.margin),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.margin),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.margin / 2),
            subtitleLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -Theme.margin),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.margin),
            editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configureCell(topic: CourierUserPreferencesTopic, availableChannels: [CourierUserPreferencesChannel]) {
        
        var subTitle = ""
                
        if (topic.status == .optedOut) {
            subTitle = "Off"
        } else if (topic.status == .required && topic.customRouting.isEmpty) {
            subTitle = "On: \(availableChannels.map { $0.rawValue }.joined(separator: ", "))"
        } else if (topic.status == .optedIn && topic.customRouting.isEmpty) {
            subTitle = "On: \(availableChannels.map { $0.rawValue }.joined(separator: ", "))"
        } else {
            subTitle = "On: \(topic.customRouting.map { $0.rawValue }.joined(separator: ", "))"
        }
        
        titleLabel.text = topic.topicName
        subtitleLabel.text = subTitle
        
    }
    
    func setTheme(theme: CourierPreferencesTheme) {
        self.selectionStyle = theme.topicCellStyles.selectionStyle
        self.titleLabel.font = theme.topicTitleFont.font
        self.titleLabel.textColor = theme.topicTitleFont.color
        self.subtitleLabel.font = theme.topicSubtitleFont.font
        self.subtitleLabel.textColor = theme.topicSubtitleFont.color
    }
    
}
