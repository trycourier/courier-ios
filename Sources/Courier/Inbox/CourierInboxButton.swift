//
//  CourierInboxButton.swift
//  
//
//  Created by Michael Miller on 3/13/23.
//

import UIKit

internal class CourierInboxButton: UIButton {

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        if #available(iOS 15.0, *) {
            configuration = .filled()
        }
        
    }
    
    internal func setTheme(_ theme: CourierInboxTheme) {
        
        titleLabel?.font = theme.retryButtonFont.font
        titleLabel?.textColor = theme.retryButtonFont.color
        
        if #available(iOS 15.0, *) {
            configuration?.baseBackgroundColor = theme.retryButtonBackgroundColor
        } else {
            backgroundColor = theme.retryButtonBackgroundColor
        }
        
    }

}
