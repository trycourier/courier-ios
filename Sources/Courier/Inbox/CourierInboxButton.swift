//
//  CourierInboxButton.swift
//  
//
//  Created by Michael Miller on 3/13/23.
//

import UIKit

internal class CourierInboxButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setTheme() {
        
        if #available(iOS 15.0, *) {
            
            var config = UIButton.Configuration.filled()
            
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = CourierInbox.theme.actionButtonFont.font
                return outgoing
            }
            
            config.baseForegroundColor = CourierInbox.theme.actionButtonFont.color
            config.baseBackgroundColor = CourierInbox.theme.actionButtonBackgroundColor
            
            configuration = config
            
        } else {
            
            contentEdgeInsets = UIEdgeInsets(top: 0, left: CourierInboxTheme.margin, bottom: 0, right: CourierInboxTheme.margin)
            layer.cornerRadius = CourierInboxTheme.margin / 2
            titleLabel?.font = CourierInbox.theme.actionButtonFont.font
            titleLabel?.textColor = CourierInbox.theme.actionButtonFont.color
            backgroundColor = CourierInbox.theme.actionButtonBackgroundColor
            
        }
        
        layoutIfNeeded()
        
    }

}
