//
//  CourierInboxTableViewCell.swift
//  
//
//  Created by Michael Miller on 3/7/23.
//

import UIKit

internal class CourierInboxTableViewCell: UITableViewCell {
    
    internal static let id = "CourierInboxTableViewCell"
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let indicatorView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        
        // Remove all subviews
        contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        // Add indicator view
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(indicatorView)
        
        indicatorView.backgroundColor = .orange
        
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            indicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            indicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            indicatorView.widthAnchor.constraint(equalToConstant: 3)
        ])
        
        // Add stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        stackView.backgroundColor = .green
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        let horizontal = CourierInboxTheme.margin * 2
        let vertical = CourierInboxTheme.margin * 1.5
        
        // Constrain the stack to the content view
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vertical),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vertical),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontal),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontal),
        ])
        
        // Add labels to stack
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(bodyLabel)
        
        titleLabel.numberOfLines = 0
        bodyLabel.numberOfLines = 0
        
        titleLabel.backgroundColor = .red
        bodyLabel.backgroundColor = .purple
        
    }
    
    private func resize() {
        bodyLabel.sizeToFit()
        titleLabel.sizeToFit()
        layoutIfNeeded()
    }
    
    internal func setMessage(_ message: InboxMessage) {
        indicatorView.isHidden = message.isRead
        titleLabel.text = message.title
        bodyLabel.text = message.subtitle
        resize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicatorView.isHidden = true
        titleLabel.text = nil
        bodyLabel.text = nil
        resize()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
