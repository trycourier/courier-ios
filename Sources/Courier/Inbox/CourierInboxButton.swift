//
//  CourierInboxButton.swift
//  
//
//  Created by Michael Miller on 3/13/23.
//

import UIKit

internal class CourierInboxButton: UIButton {
    
    internal func setTheme(_ theme: CourierInboxTheme) {
        
        let padding = CourierInboxTheme.margin * 1.5
        contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        titleLabel?.font = theme.buttonStyles.font.font
        titleLabel?.textColor = theme.buttonStyles.font.color
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
