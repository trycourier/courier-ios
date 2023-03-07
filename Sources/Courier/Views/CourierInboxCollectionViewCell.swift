//
//  CustomInboxCollectionViewCell.swift
//  Example
//
//  Created by Michael Miller on 2/28/23.
//

import UIKit

internal class CustomInboxCollectionViewCell: UICollectionViewCell {

    public static let id = "CustomInboxCollectionViewCell"
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12),
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
        ])
        
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
        
        label.text = nil
        
    }
}
