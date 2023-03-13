//
//  CourierInboxPaginationCell.swift
//  
//
//  Created by Michael Miller on 3/8/23.
//

import UIKit

internal class CourierInboxPaginationCell: UITableViewCell {
    
    internal static let id = "CourierInboxPaginationCell"
    
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
        
        // Add indicator view
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CourierInboxTheme.margin * 4),
            loadingIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CourierInboxTheme.margin * 24),
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        loadingIndicator.startAnimating()
        setTheme()
        
        // Remove cell styles
        selectionStyle = .none
        contentView.isUserInteractionEnabled = false
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingIndicator.startAnimating()
        setTheme()
    }
    
    private func setTheme() {
        loadingIndicator.color = CourierInbox.theme.loadingIndicatorColor
    }
    
}
