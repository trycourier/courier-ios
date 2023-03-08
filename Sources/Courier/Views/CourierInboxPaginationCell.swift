//
//  CourierInboxPaginationCell.swift
//  
//
//  Created by Michael Miller on 3/8/23.
//

import UIKit

internal class CourierInboxPaginationCell: UITableViewCell {
    
    internal static let height: CGFloat = 88
    internal static let id = "CourierInboxPaginationCell"
    
    private let containerView = UIView()
    private let loadingIndicator = UIActivityIndicatorView()
    
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
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        containerView.backgroundColor = .blue
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: CourierInboxPaginationCell.height)
        ])
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        // Add indicator view
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        loadingIndicator.startAnimating()
        
        // Remove cell styles
        selectionStyle = .none
        contentView.isUserInteractionEnabled = false
        
    }
    
}
