//
//  CourierInboxTableViewCell.swift
//  
//
//  Created by Michael Miller on 3/7/23.
//

import UIKit

internal class CourierInboxTableViewCell: UITableViewCell {
    
    internal static let id = "CourierInboxTableViewCell"
    
    private let indicatorView = UIView()
    
    private let stackView = UIStackView()
    
    private let titleView = UIView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    
    private let bodyLabel = UILabel()
    
    private let buttonView = UIView()
    private let buttonStack = UIStackView()
    
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
        stackView.spacing = CourierInboxTheme.margin / 2
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        let horizontal = CourierInboxTheme.margin * 2
        let vertical = CourierInboxTheme.margin * 1.5
        
        // Constrain the stack to the content view
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: vertical),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -vertical),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontal),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontal),
        ])
        
    }
    
    private func addTitle() {
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = .purple
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(titleView)
        
        stackView.layoutIfNeeded()
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(timeLabel)
        
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .red
        timeLabel.backgroundColor = .systemPink
        
        let horizontal = CourierInboxTheme.margin * 2
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
        
        titleView.layoutIfNeeded()
        
    }
    
    private func addBody() {
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bodyLabel.numberOfLines = 0
        
        bodyLabel.backgroundColor = .purple
        
        stackView.addArrangedSubview(bodyLabel)
        
        stackView.layoutIfNeeded()
        
    }
    
    private func addButtons() {
        
        buttonView.backgroundColor = .systemFill
        
        stackView.addArrangedSubview(buttonView)
        stackView.layoutIfNeeded()
        
        buttonStack.backgroundColor = .systemBlue
        buttonStack.axis = .horizontal
        
        buttonView.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: buttonView.topAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor)
        ])
        
        buttonView.layoutIfNeeded()
        
        let button1 = UIButton()
        button1.backgroundColor = .green
        button1.setTitle("Button 1", for: .normal)
        
        let button2 = UIButton()
        button2.backgroundColor = .gray
        button2.setTitle("Button 2", for: .normal)
        
        buttonStack.addArrangedSubview(button1)
        buttonStack.addArrangedSubview(button2)
        
        NSLayoutConstraint.activate([
            button1.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        NSLayoutConstraint.activate([
            button2.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        buttonStack.layoutIfNeeded()
        
        stackView.layoutIfNeeded()
        
    }
    
    private func resize() {
        timeLabel.sizeToFit()
        titleLabel.sizeToFit()
        bodyLabel.sizeToFit()
        layoutIfNeeded()
    }
    
    internal func setMessage(_ message: InboxMessage) {
        indicatorView.isHidden = message.isRead
        titleLabel.text = message.title
        timeLabel.text = message.created
        bodyLabel.text = message.subtitle
        resize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicatorView.isHidden = true
        titleLabel.text = nil
        timeLabel.text = nil
        bodyLabel.text = nil
        resize()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
