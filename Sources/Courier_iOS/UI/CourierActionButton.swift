//
//  CourierActionButton.swift
//
//
//  Created by https://github.com/mikemilla on 3/13/23.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
internal class CourierActionButton: UIButton {
    
    private let inboxAction: InboxAction?
    private let actionClick: ((InboxAction) -> Void)?
    private let onClick: (() -> Void)?
    
    internal var title: String? {
        didSet {
            setTitle(title, for: .normal)
        }
    }
    
    init(isRead: Bool, inboxAction: InboxAction, theme: CourierInboxTheme, actionClick: @escaping (InboxAction) -> Void) {
        
        self.inboxAction = inboxAction
        self.actionClick = actionClick
        self.onClick = nil
        
        super.init(frame: .zero)
        
        setTitle(inboxAction.content ?? "Action", for: .normal)
        addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
        setActionInboxTheme(theme, isRead: isRead)
        
    }
    
    init(onClick: @escaping () -> Void) {
        
        self.inboxAction = nil
        self.actionClick = nil
        self.onClick = onClick
        
        super.init(frame: .zero)
        
        addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
        
    }
    
    override init(frame: CGRect) {
        
        self.inboxAction = nil
        self.actionClick = nil
        self.onClick = nil
        
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onButtonClick() {
        if let action = inboxAction {
            actionClick?(action)
        }
        onClick?()
    }
    
    internal func setPreferencesTheme(_ theme: CourierPreferencesTheme, title: String) {
        
        setTitle(title, for: .normal)
        
        let padding = (Theme.margin / 2) * 1.5
        contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        titleLabel?.font = theme.topicButton.font.font
        titleLabel?.textColor = theme.topicButton.font.color
        setTitleColor(theme.topicButton.font.color, for: .normal)
        backgroundColor = theme.topicButton.backgroundColor
        layer.cornerRadius = theme.topicButton.cornerRadius
        
    }
    
    internal func setInfoButtonInboxTheme(_ theme: CourierInboxTheme) {
        
        let padding = (Theme.margin / 2) * 1.5
        contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        titleLabel?.font = theme.infoViewStyle.button.font.font
        titleLabel?.textColor = theme.infoViewStyle.button.font.color
        setTitleColor(theme.infoViewStyle.button.font.color, for: .normal)
        backgroundColor = theme.getInfoButtonColor()
        layer.cornerRadius = theme.infoViewStyle.button.cornerRadius
        
    }
    
    internal func setActionInboxTheme(_ theme: CourierInboxTheme, isRead: Bool) {
        
        let padding = (Theme.margin / 2) * 1.5
        contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        titleLabel?.font = isRead ? theme.buttonStyle.read.font.font : theme.buttonStyle.unread.font.font
        titleLabel?.textColor = isRead ? theme.buttonStyle.read.font.color : theme.buttonStyle.unread.font.color
        setTitleColor(isRead ? theme.buttonStyle.read.font.color : theme.buttonStyle.unread.font.color, for: .normal)
        backgroundColor = theme.getButtonColor(isRead: isRead)
        layer.cornerRadius = isRead ? theme.buttonStyle.read.cornerRadius : theme.buttonStyle.unread.cornerRadius
        
    }
    
    internal func setInfoButtonPreferencesTheme(_ theme: CourierPreferencesTheme) {
        
        let padding = (Theme.margin / 2) * 1.5
        contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        titleLabel?.font = theme.infoViewStyle.button.font.font
        titleLabel?.textColor = theme.infoViewStyle.button.font.color
        setTitleColor(theme.infoViewStyle.button.font.color, for: .normal)
        backgroundColor = theme.getInfoButtonColor()
        layer.cornerRadius = theme.infoViewStyle.button.cornerRadius
        
    }
    
    private func animate(fadeIn: Bool) {
        UIView.animate(withDuration: 0.35, delay: 0, options: .allowUserInteraction, animations: {
            self.alpha = fadeIn ? 1 : 0.5
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(fadeIn: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(fadeIn: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(fadeIn: true)
    }

}
