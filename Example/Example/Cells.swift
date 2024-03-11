//
//  ContentCollectionViewCell.swift
//  Example
//
//  Created by Michael Miller on 3/11/24.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ContentCollectionViewCell"
    
    var embeddedViewController: UIViewController? {
        willSet {
            embeddedViewController?.willMove(toParent: nil)
            embeddedViewController?.view.removeFromSuperview()
            embeddedViewController?.removeFromParent()
        }
        didSet {
            if let newViewController = embeddedViewController {
                newViewController.view.frame = contentView.bounds
                contentView.addSubview(newViewController.view)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        embeddedViewController = nil
    }
    
}

class CustomTableViewCell: UITableViewCell {
    
    static let id = "CustomTableViewCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add the label to the cell's content view
        contentView.addSubview(label)
        let padding: CGFloat = 16
        label.numberOfLines = 0
        
        // Set up constraints for the label
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class LoadingTableViewCell: UITableViewCell {
    
    static let id = "LoadingTableViewCell"
    
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add the activity indicator to the cell's content view
        contentView.addSubview(activityIndicator)
        
        // Set up constraints to center the activity indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            activityIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
