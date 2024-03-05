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
    
    private let margin = Theme.margin / 2
    
    private var horizontal: CGFloat {
        get {
            return margin * 2
        }
    }
    
    private var vertical: CGFloat {
        get {
            return margin * 1.5
        }
    }
    
    private let containerStackView = UIStackView()
    private let titleStackView = UIStackView()
    private let indicatorView = UIView()
    private let dotView = UIView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let bodyLabel = UILabel()
    private let buttonStack = UIStackView()
    private let actionsStack = UIStackView()
    private let spacer = UIView()
    
    private var inboxMessage: InboxMessage?
    
    private var containerLeading: NSLayoutConstraint?
    
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
        
        [containerStackView, titleStackView, indicatorView, dotView, titleLabel, timeLabel, bodyLabel, buttonStack, actionsStack, spacer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Add indicator
        
        contentView.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            indicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            indicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            indicatorView.widthAnchor.constraint(equalToConstant: 3)
        ])
        
        // Add container
        
        containerStackView.spacing = margin / 2
        containerStackView.insetsLayoutMarginsFromSafeArea = false
        containerStackView.axis = .vertical
        
        contentView.addSubview(containerStackView)
        
        containerLeading = containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontal)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vertical),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vertical),
            containerLeading!,
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontal),
        ])
        
        // Add title stack
        
        titleStackView.alignment = .top
        titleStackView.spacing = margin * 2
        titleStackView.axis = .horizontal
        
        containerStackView.addArrangedSubview(titleStackView)
        
        // Add title
        
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        titleStackView.addArrangedSubview(titleLabel)
        
        // Add time
        
        timeLabel.numberOfLines = 1
        timeLabel.textAlignment = .right
        
        titleStackView.addArrangedSubview(timeLabel)
        
        // Add body
        
        bodyLabel.numberOfLines = 0
        
        containerStackView.addArrangedSubview(bodyLabel)
        
        // Button Stack
        
        buttonStack.axis = .vertical
        
        containerStackView.addArrangedSubview(buttonStack)
        
        // Add spacer
        
        buttonStack.addArrangedSubview(spacer)
        
        NSLayoutConstraint.activate([
            spacer.heightAnchor.constraint(equalToConstant: margin)
        ])
        
        // Add actions stack
        
        actionsStack.spacing = margin * 1.5
        actionsStack.axis = .horizontal
        actionsStack.distribution = .fill
        
        buttonStack.addArrangedSubview(actionsStack)
        
        NSLayoutConstraint.activate([
            actionsStack.heightAnchor.constraint(equalToConstant: 34.333333333333336)
        ])
        
        contentView.addSubview(dotView)
        
        dotView.layer.cornerRadius = Theme.Inbox.indicatorDotSize / 2
        
        NSLayoutConstraint.activate([
            dotView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Inbox.indicatorDotSize / 2),
            dotView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dotView.heightAnchor.constraint(equalToConstant: Theme.Inbox.indicatorDotSize),
            dotView.widthAnchor.constraint(equalToConstant: Theme.Inbox.indicatorDotSize),
        ])
        
    }
    
    internal func setMessage(_ message: InboxMessage, _ theme: CourierInboxTheme, onActionClick: @escaping (InboxAction) -> Void) {
        
        self.inboxMessage = message
        
        setupButtons(theme, onActionClick)
        setTheme(theme, isRead: message.isRead)
        
        switch (theme.unreadIndicatorStyle.indicator) {
        case .line:
            indicatorView.isHidden = message.isRead
            dotView.isHidden = true
            break
        case .dot:
            indicatorView.isHidden = true
            dotView.isHidden = message.isRead
            break
        }
        
        titleLabel.text = message.title
        timeLabel.text = message.time
        bodyLabel.text = message.subtitle
        
    }
    
    private func setTheme(_ theme: CourierInboxTheme, isRead: Bool) {
        
        // Adjust the margin leading
        switch (theme.unreadIndicatorStyle.indicator) {
        case .line:
            containerLeading?.constant = horizontal
            break
        case .dot:
            containerLeading?.constant = Theme.Inbox.indicatorDotSize * 2
            break
        }

        indicatorView.backgroundColor = theme.unreadColor
        dotView.backgroundColor = theme.unreadColor

        // Font
        titleLabel.font = isRead ? theme.titleStyle.read.font : theme.titleStyle.unread.font
        timeLabel.font = isRead ? theme.timeStyle.read.font : theme.timeStyle.unread.font
        bodyLabel.font = isRead ? theme.bodyStyle.read.font : theme.bodyStyle.unread.font

        // Color
        titleLabel.textColor = isRead ? theme.titleStyle.read.color : theme.titleStyle.unread.color
        timeLabel.textColor = isRead ? theme.timeStyle.read.color : theme.timeStyle.unread.color
        bodyLabel.textColor = isRead ? theme.bodyStyle.read.color : theme.bodyStyle.unread.color

        // Selection style
        selectionStyle = theme.cellStyle.selectionStyle

    }
    
    private func setupButtons(_ theme: CourierInboxTheme, _ onActionClick: @escaping (InboxAction) -> Void) {
        
        let actions = self.inboxMessage?.actions ?? []
        
        // Create and add a button for each action
        actions.forEach { action in
            
            let actionButton = CourierInboxActionButton(
                isRead: self.inboxMessage?.isRead ?? true,
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
