//
//  CourierInboxButton.swift
//  
//
//  Created by https://github.com/mikemilla on 3/13/23.
//

import UIKit

internal class CourierInboxButton: UIButton {
    
    private let inboxAction: InboxAction?
    private let actionClick: ((InboxAction) -> Void)?
    private let onClick: (() -> Void)?
    
    internal var title: String? {
        didSet {
            setTitle(title, for: .normal)
        }
    }
    
    init(inboxAction: InboxAction, theme: CourierInboxTheme, actionClick: @escaping (InboxAction) -> Void) {
        
        self.inboxAction = inboxAction
        self.actionClick = actionClick
        self.onClick = nil
        
        super.init(frame: .zero)
        
        setTitle(inboxAction.content ?? "Action", for: .normal)
        addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
        setTheme(theme)
        
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
    
    internal func setTheme(_ theme: CourierInboxTheme) {
        
        let padding = CourierInboxTheme.margin * 1.5
        contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        titleLabel?.font = theme.buttonStyles.font.font
        titleLabel?.textColor = theme.buttonStyles.font.color
        setTitleColor(theme.buttonStyles.font.color, for: .normal)
        backgroundColor = theme.buttonStyles.backgroundColor
        layer.cornerRadius = theme.buttonStyles.cornerRadius
        
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
