//
//  CourierPreferenceSectionHeaderView.swift
//
//
//  Created by https://github.com/mikemilla on 3/7/24.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
class CourierPreferenceSectionHeaderView: UITableViewHeaderFooterView {
    
    static let id = "CourierPreferenceSectionHeaderView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.margin),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(title: String) {
        titleLabel.text = title
    }
    
    func setTheme(theme: CourierPreferencesTheme) {
        titleLabel.font = theme.sectionTitleFont.font
        titleLabel.textColor = theme.sectionTitleFont.color
        titleLabel.appendAccessibilityIdentifier("preferenceSectionHeader")
    }
    
}
