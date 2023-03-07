//
//  CourierInboxTableViewCell.swift
//  
//
//  Created by Michael Miller on 3/7/23.
//

import UIKit

class CourierInboxTableViewCell: UITableViewCell {
    
    internal static let id = "CourierInboxTableViewCell"
    
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    internal var message: InboxMessage? {
        didSet {
            titleLabel.text = message?.title
            bodyLabel.text = message?.body
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        message = nil
    }
    
}
