//
//  ActionButton.swift
//  Swift+Storyboard+APNS
//
//  Created by Michael Miller on 8/8/22.
//

import UIKit

class ActionButton: UIView {
    
    struct Row {
        let title: String
        let value: String?
    }
    
    var rows: [Row] = [] {
        didSet {
            
            vStack.arrangedSubviews.forEach { subview in
                subview.removeFromSuperview()
            }
            
            rows.forEach { row in
                let rowView = makeRow(row: row)
                vStack.addArrangedSubview(rowView)
            }
            
        }
    }
    
    var action: (() -> Void)? = nil
    
    var icon: String = "chevron.forward" {
        didSet {
            imageView.image = UIImage(systemName: icon)
        }
    }
    
    var title: String? = nil {
        didSet {
            if let t = title {
                setTitle(title: t)
            }
        }
    }
    
    private let vStack = UIStackView()
    private let containerStack = UIStackView()
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        
        addSubview(containerStack)
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        containerStack.backgroundColor = .clear
        containerStack.axis = .horizontal
        containerStack.spacing = 20
        containerStack.distribution = .fillProportionally
        
        // Clean
        vStack.removeFromSuperview()
        
        // Add title
        containerStack.addArrangedSubview(vStack)
        
        // Styles
        vStack.backgroundColor = .clear
        vStack.axis = .vertical
        vStack.distribution = .equalSpacing
        vStack.spacing = 20
        
        imageView.image = UIImage(systemName: icon)
        imageView.contentMode = .center
        containerStack.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
        // Add click
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ActionButton.tapAction))
        addGestureRecognizer(tapGesture)
        
    }
    
    private func setTitle(title: String) {
        
        subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    private func makeRow(row: Row) -> UIStackView {
        
        let title = UILabel()
        let value = UILabel()
        let hStack = UIStackView()
        
        hStack.alignment = .top
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 20
        
        hStack.addArrangedSubview(title)
        title.text = row.title
        
        if (row.value != nil) {
            hStack.addArrangedSubview(value)
            value.text = row.value
            value.textAlignment = .right
        } else {
            title.font = UIFont.boldSystemFont(ofSize: 20.0)
            title.textColor = .tintColor
        }
        
        title.numberOfLines = 0
        value.numberOfLines = 0
        
        return hStack
        
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
    }
    
    @objc private func tapAction() {
        action?()
    }
    
    private var alphaOnPress: CGFloat = 0.6
    private lazy var originalBackgroundColor: UIColor? = nil

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animatedDown()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateUp()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateUp()
    }
    
    private func animatedDown() {
        
        // Save the background color on press
        if (originalBackgroundColor == nil) {
            originalBackgroundColor = backgroundColor
        }
        
        self.alpha = self.alphaOnPress
        
    }

    private func animateUp() {
        self.alpha = 1
        self.backgroundColor = self.originalBackgroundColor
    }
    
}
