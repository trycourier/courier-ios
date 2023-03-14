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
    
    private var inboxMessage: InboxMessage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    internal func setMessage(_ message: InboxMessage) {
        
        self.inboxMessage = message
        
        indicatorView.isHidden = message.isRead
        titleLabel.text = message.title
        timeLabel.text = message.time
        bodyLabel.text = message.subtitle
        
        buttonStack.isHidden = !message.isRead
        
    }

    internal func updateTime() {
        if let message = self.inboxMessage {
            timeLabel.text = message.time
        }
    }
    
}