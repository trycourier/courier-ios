//
//  CourierPreferenceTopicCell.swift
//  
//
//  Created by https://github.com/mikemilla on 2/28/24.
//

import UIKit

@available(iOS 15.0, *)
@available(iOSApplicationExtension, unavailable)
internal class CourierPreferenceTopicCell: UITableViewCell {
    
    static let id = "CourierPreferenceTopicCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.appendAccessibilityIdentifier("PreferencesTopicTitleLabel")
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.appendAccessibilityIdentifier("PreferencesSubtitleLabel")
        return label
    }()
    
    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Theme.margin / 4
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var editButton: CourierActionButton = {
        let button = CourierActionButton(onClick: {
            self.onEditButtonClick?()
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        button.appendAccessibilityIdentifier("PreferencesEditButton")
        return button
    }()
    
    let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Theme.margin
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private var onEditButtonClick: (() -> Void)? = nil
    
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
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.margin),
            editButton.widthAnchor.constraint(lessThanOrEqualToConstant: 68),
            editButton.heightAnchor.constraint(equalToConstant: Theme.Preferences.actionButtonMaxHeight)
        ])
    }
    
    func configureCell(topic: CourierUserPreferencesTopic, mode: CourierPreferences.Mode, onEditButtonClick: @escaping () -> Void) {
        
        backgroundColor = .clear
        
        self.titleLabel.text = topic.topicName
        self.onEditButtonClick = onEditButtonClick
        
        switch (mode) {
        case .topic:
            
            subtitleLabel.text = topic.status.title
            
        case .channels(let availableChannels):
            
            var subTitle = ""
    
            if (topic.status == .optedOut) {
                subTitle = "Off"
            } else if (topic.status == .required && topic.customRouting.isEmpty) {
                subTitle = "On: \(availableChannels.map { $0.title }.joined(separator: ", "))"
            } else if (topic.status == .optedIn && topic.customRouting.isEmpty) {
                subTitle = "On: \(availableChannels.map { $0.title }.joined(separator: ", "))"
            } else {
                subTitle = "On: \(topic.customRouting.map { $0.title }.joined(separator: ", "))"
            }
            
            subtitleLabel.text = subTitle
        }
        
    }
    
    func setTheme(theme: CourierPreferencesTheme) {
        self.editButton.setPreferencesTheme(theme, title: "Edit")
        self.selectionStyle = theme.topicCellStyles.selectionStyle
        self.titleLabel.font = theme.topicTitleFont.font
        self.titleLabel.textColor = theme.topicTitleFont.color
        self.subtitleLabel.font = theme.topicSubtitleFont.font
        self.subtitleLabel.textColor = theme.topicSubtitleFont.color

        self.appendAccessibilityIdentifier("PreferenceTopic")
    }
    
}
