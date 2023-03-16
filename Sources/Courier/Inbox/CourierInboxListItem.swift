//
//  CourierInboxListItem.swift
//  
//
//  Created by Michael Miller on 3/14/23.
//

import UIKit

internal struct CourierInboxListItemButton {
    let action: InboxAction
    let event: () -> Void
}

internal class CourierInboxListItem: UITableViewCell {
    
    internal static let id = "CourierInboxListItem"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var actionsStack: UIStackView!
    
    private var inboxMessage: InboxMessage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
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
            spacer.backgroundColor = .red
            actionsStack.addArrangedSubview(spacer)
        }
        
        buttonStack.isHidden = actions.isEmpty
        
    }
    
    private func setTheme(_ theme: CourierInboxTheme) {

        indicatorView.backgroundColor = theme.unreadIndicatorBarColor

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

    internal func updateTime() {
        if let message = self.inboxMessage {
            timeLabel.text = message.time
        }
    }
    
}
