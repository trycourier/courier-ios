//
//  CourierInboxTableViewCell.swift
//  Example
//
//  Created by Michael Miller on 2/28/23.
//

import UIKit

internal class CourierInboxTableViewCell: UITableViewCell {

    internal static let id = "CourierInboxTableViewCell"
    
    internal var message: InboxMessage? {
        didSet {
            titleLabel.text = message?.messageId
        }
    }
    
    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(bodyLabel)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12),
            contentStack.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
        ])
        
        contentStack.backgroundColor = .blue
        titleLabel.backgroundColor = .red
        bodyLabel.backgroundColor = .brown
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("Interface Builder is not supported!")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        fatalError("Interface Builder is not supported!")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        message = nil
    }
    
}
