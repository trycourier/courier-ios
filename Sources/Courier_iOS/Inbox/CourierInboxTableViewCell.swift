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
    
    internal static let dotSize = 10.0
    
    private let margin = CourierInboxTheme.margin
    
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
        
        // TODO: Add dot
        
        contentView.addSubview(dotView)
        
        dotView.layer.cornerRadius = CourierInboxTableViewCell.dotSize / 2
        
        NSLayoutConstraint.activate([
            dotView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CourierInboxTableViewCell.dotSize / 2),
            dotView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dotView.heightAnchor.constraint(equalToConstant: CourierInboxTableViewCell.dotSize),
            dotView.widthAnchor.constraint(equalToConstant: CourierInboxTableViewCell.dotSize),
        ])
        
    }
    
    internal func setMessage(_ message: InboxMessage, _ theme: CourierInboxTheme, onActionClick: @escaping (InboxAction) -> Void) {
        
        self.inboxMessage = message
        
        setupButtons(theme, onActionClick)
        setTheme(theme)

        indicatorView.isHidden = theme.unreadIndicator?.style == .dot ? false : message.isRead
        dotView.isHidden = theme.unreadIndicator?.style == .line ? false : message.isRead
        
        titleLabel.text = message.title
        timeLabel.text = message.time
        bodyLabel.text = message.subtitle
        
    }
    
    private func setTheme(_ theme: CourierInboxTheme) {
        
        // Adjust the margin leading
        containerLeading?.constant = theme.unreadIndicator?.style == .dot ? CourierInboxTableViewCell.dotSize * 2 : horizontal

        indicatorView.backgroundColor = theme.unreadColor
        dotView.backgroundColor = theme.unreadColor

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
        
        let actions = self.inboxMessage?.actions ?? []
        
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
