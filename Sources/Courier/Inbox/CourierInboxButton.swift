//
//  CourierInboxButton.swift
//  
//
//  Created by Michael Miller on 3/13/23.
//

import UIKit

internal class CourierInboxButton: UIButton {
    
    internal func setTheme(_ theme: CourierInboxTheme) {
        
        contentEdgeInsets = UIEdgeInsets(top: 0, left: CourierInboxTheme.margin, bottom: 0, right: CourierInboxTheme.margin)
        titleLabel?.font = theme.buttonStyles.font.font
        titleLabel?.textColor = theme.buttonStyles.font.color
        backgroundColor = theme.buttonStyles.backgroundColor
        layer.cornerRadius = theme.buttonStyles.cornerRadius
        
//        if #available(iOS 15.0, *) {
//
//            var config = UIButton.Configuration.filled()
//
//            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
//                var outgoing = incoming
//                outgoing.font = theme.buttonStyles.font?.font
//                return outgoing
//            }
//
//            config.baseForegroundColor = theme.buttonStyles.font?.color
//            config.baseBackgroundColor = theme.buttonStyles.backgroundColor
//
//            configuration = config
//
//        } else {
//
//            contentEdgeInsets = UIEdgeInsets(top: 0, left: CourierInboxTheme.margin, bottom: 0, right: CourierInboxTheme.margin)
//            layer.cornerRadius = CourierInboxTheme.margin / 2
//            titleLabel?.font = theme.buttonStyles.font?.font
//            titleLabel?.textColor = theme.buttonStyles.font?.color
//            backgroundColor = theme.buttonStyles.backgroundColor
//
//        }
        
    }
    
    private func animate(fadeIn: Bool) {
        UIView.animate(withDuration: 0.6, animations: {
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
