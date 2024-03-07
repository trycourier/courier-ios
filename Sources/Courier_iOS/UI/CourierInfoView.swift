//
//  CourierInfoView.swift
//
//
//  Created by https://github.com/mikemilla on 3/13/23.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
internal class CourierInfoView: UIView {
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let buttonContainer = UIView()
    private lazy var actionButton: CourierActionButton = {
        CourierActionButton { [weak self] in
            self?.onButtonClick?()
        }
    }()
    
    internal var onButtonClick: (() -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        [stackView, titleLabel, actionButton, buttonContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addStack()
        addTitle()
        addButton()
        
    }
    
    private func addStack() {
        
        stackView.spacing = (Theme.margin / 2) * 2
        stackView.axis = .vertical
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
    }
    
    private func addTitle() {
        
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(titleLabel)
        
    }
    
    private func addButton() {
        
        buttonContainer.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: Theme.Inbox.actionButtonMaxHeight),
            actionButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
        ])
        
        stackView.addArrangedSubview(buttonContainer)
        
    }
    
    @objc private func onActionButtonClick() {
        onButtonClick?()
    }
    
    internal func updateView(_ state: State) {
        
        switch (state) {
        case .error(let error):
            titleLabel.isHidden = false
            buttonContainer.isHidden = false
            actionButton.title = "Retry"
            let e = CourierError(from: error)
            titleLabel.text = e.message
        case .empty:
            titleLabel.isHidden = false
            buttonContainer.isHidden = true
            titleLabel.text = "No messages found"
        default:
            titleLabel.isHidden = true
            buttonContainer.isHidden = true
        }
        
    }
    
    internal func setTheme(_ theme: CourierInboxTheme) {
        titleLabel.font = theme.infoViewStyle.font.font
        titleLabel.textColor = theme.infoViewStyle.font.color
        actionButton.setInfoButtonInboxTheme(theme)
    }
    
}
