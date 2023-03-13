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
        
//        if #available(iOS 15.0, *) {
//            configuration = .filled()
//        }
        
    }
    
    internal func setTheme(_ theme: CourierInboxTheme) {
        
        titleLabel?.font = theme.retryButtonFont.font
        titleLabel?.textColor = theme.retryButtonFont.color
        backgroundColor = theme.retryButtonBackgroundColor
        
//        if #available(iOS 15.0, *) {
//
//            var style = UIButton.Configuration.filled()
//            var background = UIButton.Configuration.filled().background
//            style.background = theme.retryButtonBackgroundColor
//
//            return style
//
//            let attributedString = AttributedString((String(describing: title)))
//            attributedString.font = theme.retryButtonFont.font
//            attributedString.foregroundColor = theme.retryButtonFont.color
//
//            let config = configuration.updated(for: self)
//            let config = config.background.backgroundColor
//            print(b2)
//
//            configuration?.attributedTitle = attributedString
//            configuration?.baseBackgroundColor = theme.retryButtonBackgroundColor
//        } else {
//            titleLabel?.font = theme.retryButtonFont.font
//            titleLabel?.textColor = theme.retryButtonFont.color
//            backgroundColor = theme.retryButtonBackgroundColor
//        }
        
    }

}
