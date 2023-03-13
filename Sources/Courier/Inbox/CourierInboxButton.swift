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
                outgoing.font = theme.retryButtonFont.font
                return outgoing
            }
            
            config.baseForegroundColor = theme.retryButtonFont.color
            config.baseBackgroundColor = theme.retryButtonBackgroundColor
            
            configuration = config
            
        } else {
            
            titleLabel?.font = theme.retryButtonFont.font
            titleLabel?.textColor = theme.retryButtonFont.color
            backgroundColor = theme.retryButtonBackgroundColor
            
        }
        
    }

}
