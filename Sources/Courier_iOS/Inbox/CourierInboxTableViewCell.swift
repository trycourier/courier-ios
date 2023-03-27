//
//  CourierInboxTableViewCell.swift
//  
//
//  Created by https://github.com/mikemilla on 3/23/23.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
internal class CourierInboxTableViewCell: UITableViewCell {
    
    internal static let id = "CourierInboxTableViewCell"
    
    private let containerStackView = UIStackView()
    private let titleStackView = UIStackView()
    private let indicatorView = UIView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let bodyLabel = UILabel()
    private let buttonStack = UIStackView()
    private let actionsStack = UIStackView()
    
    private var inboxMessage: InboxMessage?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    private func setup() {
        
        let margin = CourierInboxTheme.margin
        
        // Add indicator
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            indicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            indicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            indicatorView.widthAnchor.constraint(equalToConstant: 3)
        ])
        
        // Add container
        
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.spacing = margin / 2
        containerStackView.insetsLayoutMarginsFromSafeArea = false
        containerStackView.axis = .vertical
        
        contentView.addSubview(containerStackView)
        
        let horizontal = margin * 2
        let vertical = margin * 1.5
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vertical),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vertical),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontal),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontal),
        ])
        
        // Add title stack
        
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.alignment = .top
        titleStackView.spacing = margin * 2
        titleStackView.axis = .horizontal
        
        containerStackView.addArrangedSubview(titleStackView)
        
        // Add title
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        titleStackView.addArrangedSubview(titleLabel)
        
        // Add time
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.numberOfLines = 1
        timeLabel.textAlignment = .right
        
        titleStackView.addArrangedSubview(timeLabel)
        
        // Add body
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.numberOfLines = 0
        
        containerStackView.addArrangedSubview(bodyLabel)
        
        // Button Stack
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        containerStackView.addArrangedSubview(buttonStack)
        
        // Add spacer
        
        let spacer = UIView()
        
        spacer.translatesAutoresizingMaskIntoConstraints = false
        
        buttonStack.addArrangedSubview(spacer)
        
        NSLayoutConstraint.activate([
            spacer.heightAnchor.constraint(equalToConstant: margin)
        ])
        
        // Add actions stack
        
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        actionsStack.spacing = margin * 1.5
        actionsStack.axis = .horizontal
        
        buttonStack.addArrangedSubview(actionsStack)
        
        NSLayoutConstraint.activate([
            actionsStack.heightAnchor.constraint(equalToConstant: 34.333333333333336)
        ])
        
    }
    
    internal func setMessage(_ message: InboxMessage, _ theme: CourierInboxTheme, onActionClick: @escaping (InboxAction) -> Void) {
        
        self.inboxMessage = message
        
        setupButtons(theme, onActionClick)
        setTheme(theme)

        indicatorView.isHidden = message.isRead
        titleLabel.text = message.title
        timeLabel.text = message.time
        bodyLabel.text = message.subtitle
        
    }
    
    private func setTheme(_ theme: CourierInboxTheme) {

        indicatorView.backgroundColor = theme.unreadColor

        // Font
        titleLabel.font = theme.titleFont.font
        timeLabel.font = theme.timeFont.font
        bodyLabel.font = theme.bodyFont.font

        // Color
        titleLabel.textColor = theme.titleFont.color
        timeLabel.textColor = theme.timeFont.color
        bodyLabel.textColor = theme.bodyFont.color

        // Selection style
        selectionStyle = theme.cellStyles.selectionStyle

    }
    
    private func setupButtons(_ theme: CourierInboxTheme, _ onActionClick: @escaping (InboxAction) -> Void) {
        
//        let actions = self.inboxMessage?.actions ?? []
        let actions = [
            InboxAction(content: "Something", href: "", style: "", background_color: ""),
            InboxAction(content: "Something Else", href: "", style: "", background_color: ""),
        ]
        
        // Create and add a button for each action
        actions.forEach { action in
            
            let actionButton = CourierInboxButton(
                inboxAction: action,
                theme: theme,
                actionClick: onActionClick
            )
            
            actionsStack.addArrangedSubview(actionButton)
            
        }
        
        // Add spacer to end
        // Pushes items to left
        if (!actions.isEmpty) {
            let spacer = UIView()
            actionsStack.addArrangedSubview(spacer)
        }
        
        buttonStack.isHidden = actions.isEmpty
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    private func reset() {
        indicatorView.isHidden = true
        titleLabel.text = nil
        timeLabel.text = nil
        bodyLabel.text = nil
        actionsStack.arrangedSubviews.forEach { subview in
            subview.removeFromSuperview()
        }
        buttonStack.isHidden = true
    }

}
