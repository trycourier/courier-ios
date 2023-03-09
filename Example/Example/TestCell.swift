//
//  TestCell.swift
//  Example
//
//  Created by Michael Miller on 3/9/23.
//

import UIKit

internal class TestCell: UITableViewCell {
    
    internal static let id = "TestCell"
    
    private let indicatorView = UIView()
    
    private let stackView = UIStackView()
    
    private let titleView = UIView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    
    private let bodyLabel = UILabel()
    
    private let buttonView = UIView()
    private let buttonStack = UIStackView()
    private let button1 = UIButton(type: .system)
    private let button2 = UIButton(type: .system)
    
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
        
        contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        addIndicator()
        addStack()
        addTitle()
        addBody()
        addButtons()
        
    }
    
    private func addIndicator() {
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(indicatorView)
        
        indicatorView.backgroundColor = .orange
        
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            indicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            indicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            indicatorView.widthAnchor.constraint(equalToConstant: 3)
        ])
        
    }
    
    private func addStack() {
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        stackView.backgroundColor = .green
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        // Constrain the stack to the content view
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
    }
    
    private func addTitle() {
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = .purple
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(titleView)
        
//        stackView.layoutIfNeeded()
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(timeLabel)
        
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .red
        timeLabel.backgroundColor = .systemPink
        
        let horizontal: CGFloat = 16
        let timeLabelWidth: CGFloat = 80
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -(timeLabelWidth + horizontal)),
            timeLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            timeLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: timeLabelWidth)
        ])
        
//        titleView.layoutIfNeeded()
        
    }
    
    private func addBody() {
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bodyLabel.numberOfLines = 0
        
        bodyLabel.backgroundColor = .purple
        
        stackView.addArrangedSubview(bodyLabel)
        
//        stackView.layoutIfNeeded()
        
    }
    
    private func addButtons() {
        
        
        
//        buttonView.backgroundColor = .systemFill
//
//        stackView.addArrangedSubview(buttonView)
        
//        NSLayoutConstraint.activate([
//            buttonView.heightAnchor.constraint(equalToConstant: 40),
//        ])

//        stackView.addArrangedSubview(buttonView)
//        stackView.layoutIfNeeded()
//
//        buttonStack.backgroundColor = .systemBlue
//        buttonStack.axis = .horizontal
//
//        buttonView.addSubview(buttonStack)

//        NSLayoutConstraint.activate([
//            buttonStack.topAnchor.constraint(equalTo: buttonView.topAnchor),
//            buttonStack.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
//            buttonStack.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor),
//            buttonStack.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor)
//        ])

//        buttonView.layoutIfNeeded()
        
        buttonStack.backgroundColor = .systemBlue
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fill
        
        button1.backgroundColor = .gray
        button1.setTitle("Button 1", for: .normal)

        button2.backgroundColor = .gray
        button2.setTitle("Button 2", for: .normal)
        
        buttonStack.addArrangedSubview(button1)
        buttonStack.addArrangedSubview(button2)
        
        let spacer = UIView()
        spacer.isUserInteractionEnabled = false
        spacer.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        
        buttonStack.addArrangedSubview(spacer)
        
        stackView.addArrangedSubview(buttonStack)

//        buttonView.addSubview(button1)
////        buttonView.addSubview(button2)
//
//        NSLayoutConstraint.activate([
//            button1.topAnchor.constraint(equalTo: buttonView.topAnchor),
//            button1.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
//            button1.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor),
//            button1.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor),
//        ])

//        NSLayoutConstraint.activate([
//            button2.topAnchor.constraint(equalTo: buttonView.topAnchor),
//            button2.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
//            button2.leadingAnchor.constraint(equalTo: button1.trailingAnchor),
//        ])
//
//        buttonView.layoutIfNeeded()
//
//        stackView.addArrangedSubview(buttonView)
//
//        stackView.layoutIfNeeded()

//        buttonStack.addArrangedSubview(button1)
//        buttonStack.addArrangedSubview(button2)
//
//        buttonStack.layoutIfNeeded()
//
//        stackView.layoutIfNeeded()
        
    }
    
    private func resize() {
//        timeLabel.sizeToFit()
//        titleLabel.sizeToFit()
//        bodyLabel.sizeToFit()
//        buttonView.sizeToFit()
//        button1.sizeToFit()
//        button2.sizeToFit()
        
//        buttonView.sizeToFit()
        
        layoutIfNeeded()
    }
    
    internal func setItem(item: Item) {
        indicatorView.isHidden = false
        titleLabel.text = item.title
        timeLabel.text = "999"
        bodyLabel.text = item.body
        resize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        indicatorView.isHidden = false
//        titleLabel.text = nil
//        timeLabel.text = nil
//        bodyLabel.text = nil
//        resize()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
