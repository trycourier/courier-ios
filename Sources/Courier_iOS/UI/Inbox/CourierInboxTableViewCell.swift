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
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = margin / 2
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .top
        stackView.spacing = margin * 2
        stackView.axis = .horizontal
        return stackView
    }()

    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var dotView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Theme.Inbox.indicatorDotSize / 2
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()

    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private lazy var buttonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var actionsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = margin * 1.5
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var spacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var inboxMessage: InboxMessage?
    private var onActionClick: ((InboxAction) -> Void)?
    private var theme: CourierInboxTheme?
    
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
        
        contentView.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            indicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            indicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            indicatorView.widthAnchor.constraint(equalToConstant: 3)
        ])
        
        contentView.addSubview(containerStackView)
        
        containerLeading = containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontal)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vertical),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vertical),
            containerLeading!,
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontal),
        ])
        
        containerStackView.addArrangedSubview(titleStackView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(timeLabel)
        containerStackView.addArrangedSubview(bodyLabel)
        containerStackView.addArrangedSubview(buttonStack)
        buttonStack.addArrangedSubview(spacer)
        
        NSLayoutConstraint.activate([
            spacer.heightAnchor.constraint(equalToConstant: margin)
        ])
        
        buttonStack.addArrangedSubview(actionsStack)
        
        NSLayoutConstraint.activate([
            actionsStack.heightAnchor.constraint(equalToConstant: 34.333333333333336)
        ])
        
        contentView.addSubview(dotView)
        
        NSLayoutConstraint.activate([
            dotView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Inbox.indicatorDotSize / 2),
            dotView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dotView.heightAnchor.constraint(equalToConstant: Theme.Inbox.indicatorDotSize),
            dotView.widthAnchor.constraint(equalToConstant: Theme.Inbox.indicatorDotSize),
        ])
        
    }
    
    internal func setMessage(_ message: InboxMessage, _ theme: CourierInboxTheme, onActionClick: @escaping (InboxAction) -> Void) {
        
        self.theme = theme
        self.inboxMessage = message
        self.onActionClick = onActionClick
        
        refreshMessage(message)
        
    }
    
    func refreshMessage(_ message: InboxMessage) {
        
        guard let theme = self.theme, let onActionClick = self.onActionClick else {
            return
        }
        
        self.inboxMessage = message
        
        titleLabel.text = message.title
        timeLabel.text = message.time
        bodyLabel.text = message.subtitle
        
        setupButtons(message, theme, onActionClick)
        setTheme(theme, isRead: message.isRead && !message.isArchived)
        
    }
    
    private func setTheme(_ theme: CourierInboxTheme, isRead: Bool) {
        
        // Adjust the margin leading
        switch (theme.unreadIndicatorStyle.indicator) {
        case .line:
            containerLeading?.constant = horizontal
            indicatorView.isHidden = isRead
            dotView.isHidden = true
            break
        case .dot:
            containerLeading?.constant = Theme.Inbox.indicatorDotSize * 2
            indicatorView.isHidden = true
            dotView.isHidden = isRead
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
    
    private func setupButtons(_ message: InboxMessage, _ theme: CourierInboxTheme, _ onActionClick: @escaping (InboxAction) -> Void) {
        
        // Remove existing buttons
        actionsStack.arrangedSubviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        // Add new actions
        let actions = message.actions ?? []
        
        // Create and add a button for each action
        actions.forEach { action in
            
            let actionButton = CourierActionButton(
                isRead: message.isRead,
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
        dotView.isHidden = true
        titleLabel.text = nil
        timeLabel.text = nil
        bodyLabel.text = nil
        actionsStack.arrangedSubviews.forEach { subview in
            subview.removeFromSuperview()
        }
        buttonStack.isHidden = true
    }

}
