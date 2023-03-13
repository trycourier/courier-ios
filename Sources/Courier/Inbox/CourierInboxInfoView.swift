//
//  CourierInboxInfoView.swift
//  
//
//  Created by Michael Miller on 3/13/23.
//

import UIKit

internal class CourierInboxInfoView: UIView {
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let actionButton = CourierInboxButton(type: .system)
    private let buttonContainer = UIView()
    
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
        
        addStack()
        addTitle()
        addButton()
        
    }
    
    private func addStack() {
        
        stackView.spacing = CourierInboxTheme.margin * 2
        stackView.axis = .vertical
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(onActionButtonClick), for: .touchUpInside)
        
        buttonContainer.addSubview(actionButton)
        buttonContainer.backgroundColor = .blue
        
        NSLayoutConstraint.activate([
            actionButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
        ])
        
        stackView.addArrangedSubview(buttonContainer)
        
    }
    
    @objc private func onActionButtonClick() {
        onButtonClick?()
    }
    
    internal func updateView(_ state: CourierInbox.State) {
        
        switch (state) {
        case .error(let error):
            titleLabel.isHidden = false
            buttonContainer.isHidden = false
            actionButton.setTitle("Retry", for: .normal)
            titleLabel.text = error.friendlyMessage + "asdkja sdkj asljkd ajlksd jasdkjl alksd jlkasd kjlaskljd jalsdj alskd jalsdj lasjd lkasd "
        case .empty:
            titleLabel.isHidden = false
            buttonContainer.isHidden = true
            titleLabel.text = "No messages found"
        default:
            titleLabel.isHidden = true
            buttonContainer.isHidden = true
        }
        
    }
    
}
