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
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Theme.margin
        stackView.backgroundColor = .cyan
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .green
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        return button
    }()
    
    let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Theme.margin
        stackView.backgroundColor = .red
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
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
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subtitleLabel)
        
        contentStackView.addArrangedSubview(verticalStackView)
        contentStackView.addArrangedSubview(editButton)
        
        contentView.addSubview(contentStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.margin),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.margin),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.margin),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.margin)
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
