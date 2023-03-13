//
//  Courierbar.swift
//  
//
//  Created by Michael Miller on 3/13/23.
//

import UIKit

internal class CourierBar: UIView {

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        subviews.forEach {
            $0.removeFromSuperview()
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        backgroundColor = .red
        stackView.backgroundColor = .purple
        
        // Add label
        
        let label = UILabel()
        label.backgroundColor = .green
        label.text = "Powered by"
        
        stackView.addArrangedSubview(label)
        
        // Add image
        
        let imageView = UIImageView()
        imageView.backgroundColor = .orange
        
        stackView.addArrangedSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.widthAnchor.constraint(equalToConstant: 200),
        ])
        
    }

}
