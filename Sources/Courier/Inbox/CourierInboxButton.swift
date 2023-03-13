//
//  CourierInboxButton.swift
//  
//
//  Created by Michael Miller on 3/13/23.
//

import UIKit

internal class CourierInboxButton: UIButton {
    
    internal func setTheme() {
        
        if #available(iOS 15.0, *) {
            
            var config = UIButton.Configuration.filled()
            
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = CourierInbox.theme.retryButtonFont.font
                return outgoing
            }
            
            config.baseForegroundColor = CourierInbox.theme.retryButtonFont.color
            config.baseBackgroundColor = CourierInbox.theme.retryButtonBackgroundColor
            
            configuration = config
            
        } else {
            
            titleLabel?.font = CourierInbox.theme.retryButtonFont.font
            titleLabel?.textColor = CourierInbox.theme.retryButtonFont.color
            backgroundColor = CourierInbox.theme.retryButtonBackgroundColor
            
        }
        
    }

}
