//
//  CourierInboxListItem.swift
//  
//
//  Created by Michael Miller on 3/14/23.
//

import UIKit

class CourierInboxListItem: UITableViewCell {
    
    internal static let id = "CourierInboxListItem"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var leftButton: CourierInboxButton!
    @IBOutlet weak var rightButton: CourierInboxButton!
    
    private var inboxMessage: InboxMessage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    internal func setMessage(_ message: InboxMessage, theme: CourierInboxTheme) {
        
        setTheme(theme)
        
        self.inboxMessage = message
        
        indicatorView.isHidden = message.isRead
        titleLabel.text = message.title
        timeLabel.text = message.time
        bodyLabel.text = message.subtitle
        
        buttonStack.isHidden = !message.isRead
        
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

        // Buttons
        [leftButton, rightButton].forEach { button in
            button.setTheme(theme)
        }
        
        leftButton.setTitle("Example One", for: .normal)
        rightButton.setTitle("Example Two", for: .normal)

        // Selection style
        selectionStyle = theme.cellStyles.selectionStyle

    }

    internal func updateTime() {
        if let message = self.inboxMessage {
            timeLabel.text = message.time
        }
    }
    
}
