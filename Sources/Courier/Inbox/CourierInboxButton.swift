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
            configuration?.baseBackgroundColor = .systemRed
        } else {
            // Fallback on earlier versions
        }
        
    }

}
