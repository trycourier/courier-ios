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
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = Theme.margin / 2
        return stackView
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
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        contentView.addSubview(stackView)
        contentView.addSubview(editButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.margin),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.margin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Theme.margin),
            editButton.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: Theme.margin),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.margin),
            editButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
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
