//
//  CustomInboxCollectionViewCell.swift
//  Example
//
//  Created by Michael Miller on 2/28/23.
//

import UIKit

internal class CustomInboxCollectionViewCell: UICollectionViewCell {

    public static let id = "CustomInboxCollectionViewCell"
    weak var label: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        let textLabel = UILabel(frame: .zero)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            textLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            textLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width) // TODO
        ])
        
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        
        label = textLabel
        
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
