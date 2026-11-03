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
        // Long section names wrap instead of running off the trailing edge
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)

        // Below required so the table's first layout pass, before it knows the height, doesn't conflict
        let bottom = titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.margin)
        bottom.priority = .defaultHigh

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.margin),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.margin),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.margin),
            bottom
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
        titleLabel.appendAccessibilityIdentifier("PreferencesSectionTitleLabel")
    }
    
}
