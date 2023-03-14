//
//  CourierInboxButton.swift
//  
//
//  Created by Michael Miller on 3/13/23.
//

import UIKit

internal class CourierInboxButton: UIButton {
    
    internal func setTheme(_ theme: CourierInboxTheme) {
        
        if #available(iOS 15.0, *) {
            
            var config = UIButton.Configuration.filled()
            
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = theme.actionButtonFont.font
                return outgoing
            }
            
            config.baseForegroundColor = theme.actionButtonFont.color
            config.baseBackgroundColor = theme.actionButtonBackgroundColor
            
            configuration = config
            
        } else {
            
            contentEdgeInsets = UIEdgeInsets(top: 0, left: CourierInboxTheme.margin, bottom: 0, right: CourierInboxTheme.margin)
            layer.cornerRadius = CourierInboxTheme.margin / 2
            titleLabel?.font = theme.actionButtonFont.font
            titleLabel?.textColor = theme.actionButtonFont.color
            backgroundColor = theme.actionButtonBackgroundColor
            
        }
        
    }

}
