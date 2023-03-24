//
//  CourierInboxTableViewCell.swift
//  
//
//  Created by https://github.com/mikemilla on 3/23/23.
//

import UIKit

internal class CourierInboxTableViewCell: UITableViewCell {
    
    internal static let id = "CourierInboxTableViewCell"
    
    let label = UILabel()
    
    private let containerStackView = UIStackView()
    
    private var inboxMessage: InboxMessage?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        // Add container
        
        containerStackView.backgroundColor = .green
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.spacing = 4
        containerStackView.insetsLayoutMarginsFromSafeArea = false
        
        contentView.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
        // Test
        containerStackView.addArrangedSubview(label)
        
    }
    
    internal func setMessage(_ message: InboxMessage, _ theme: CourierInboxTheme, onActionClick: @escaping (InboxAction) -> Void) {
        
        self.inboxMessage = message
        
        label.text = message.subtitle
        
//        setupButtons(theme, onActionClick)
//        setTheme(theme)
//
//        indicatorView.isHidden = message.isRead
//        titleLabel.text = message.title
//        timeLabel.text = message.time
//        bodyLabel.text = message.subtitle
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
