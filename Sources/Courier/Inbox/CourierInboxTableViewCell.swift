//
//  CourierInboxTableViewCell.swift
//  
//
//  Created by Michael Miller on 3/7/23.
//

import UIKit

internal class CourierInboxTableViewCell: UITableViewCell {
    
    internal static let id = "CourierInboxTableViewCell"
    
    private var tableViewWidth: CGFloat = 0
    
    private let indicatorView = UIView()
    
    private let stackView = UIStackView()
    
    private let titleView = UIView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    
    private let bodyLabel = UILabel()
    
    private let buttonTopSpacer = UIView()
    private let buttonStack = UIStackView()
    private let button1 = CourierInboxButton(type: .system)
    private let button2 = CourierInboxButton(type: .system)
    
    private let timeLabelWidth: CGFloat = 80
    private let horizontalMargin: CGFloat = CourierInboxTheme.margin * 2
    private let verticalMargin: CGFloat = CourierInboxTheme.margin * 1.5
    
    private var inboxMessage: InboxMessage? = nil
    
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
        
        setTheme()
        
    }
    
    private func addIndicator() {
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            indicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            indicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            indicatorView.widthAnchor.constraint(equalToConstant: 3)
        ])
        
    }
    
    private func addStack() {
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        // Constrain the stack to the content view
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalMargin),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalMargin),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalMargin),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalMargin),
        ])
        
    }
    
    private func addTitle() {
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(titleView)
        
        stackView.layoutIfNeeded()
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(timeLabel)
        
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.numberOfLines = 1
        timeLabel.textAlignment = .right
        
        titleLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -(timeLabelWidth + horizontalMargin)),
            timeLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            timeLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: timeLabelWidth)
        ])
        
    }
    
    private func addBody() {
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bodyLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(bodyLabel)
        
    }
    
    private func addButtons() {
        
        // Add a top spacer
        
        buttonTopSpacer.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(buttonTopSpacer)
        
        NSLayoutConstraint.activate([
            buttonTopSpacer.heightAnchor.constraint(equalToConstant: CourierInboxTheme.margin)
        ])
        
        // Create the button stack
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fill
        
        button1.setTitle("Update me", for: .normal)
        button2.setTitle("Me too", for: .normal)
        
        buttonStack.addArrangedSubview(button1)
        buttonStack.addArrangedSubview(button2)
        
        let spacer = UIView()
        spacer.isUserInteractionEnabled = false
        spacer.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        
        buttonStack.addArrangedSubview(spacer)
        
        stackView.addArrangedSubview(buttonStack)
        
    }
    
    internal func setMessage(_ message: InboxMessage, width: CGFloat) {
        
        inboxMessage = message
        tableViewWidth = width
        
        indicatorView.isHidden = message.isRead
        titleLabel.text = message.title
        timeLabel.text = message.time
        bodyLabel.text = message.subtitle
        
        bodyLabel.isHidden = false
        buttonStack.isHidden = false
        
        refresh()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        inboxMessage = nil

        indicatorView.isHidden = true
        titleLabel.text = nil
        timeLabel.text = nil
        bodyLabel.text = nil
        
        bodyLabel.isHidden = true
        buttonStack.isHidden = true

        refresh()

    }
    
    internal func updateTime() {
        if let message = inboxMessage {
            timeLabel.text = message.time
        }
    }
    
    private func refresh() {
        
        // Fixes layout bug with title
        titleView.layoutIfNeeded()
        
    }
    
    private func setTheme() {
        
        indicatorView.backgroundColor = CourierInbox.theme.unreadIndicatorBarColor
        
        // Font
        titleLabel.font = CourierInbox.theme.titleFont.font
        timeLabel.font = CourierInbox.theme.timeFont.font
        bodyLabel.font = CourierInbox.theme.bodyFont.font
        
        // Color
        titleLabel.textColor = CourierInbox.theme.titleFont.color
        timeLabel.textColor = CourierInbox.theme.timeFont.color
        bodyLabel.textColor = CourierInbox.theme.bodyFont.color
        
        // Buttons
        button1.setTheme()
        button2.setTheme()
        
        // Selection style
        selectionStyle = CourierInbox.theme.cellStyles.selectionStyle
        
    }
    
    private func setMaxWidth() {
        let contentWidth = tableViewWidth - (horizontalMargin * 2)
        titleLabel.preferredMaxLayoutWidth = contentWidth - (timeLabelWidth + horizontalMargin)
        timeLabel.preferredMaxLayoutWidth = timeLabelWidth
        bodyLabel.preferredMaxLayoutWidth = contentWidth
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure we can resize
        setMaxWidth()
        
        // Reload the theme
        setTheme()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
